class UploadsController < ApplicationController
  before_action :set_upload, only: [ :show, :destroy, :regenerate_questions, :edit, :update, :toggle_show_answers ]

  def toggle_show_answers
    @upload.update(show_answers: !@upload.show_answers)
    redirect_to @upload, notice: (@upload.show_answers? ? "Answers are now visible." : "Answers are now hidden.")
  end

  def edit
    # @upload is set by before_action
  end

  def update
    # @upload is set by before_action
    if @upload.update(upload_update_params)
      redirect_to uploads_path, notice: "Upload updated successfully."
    else
      render :edit
    end
  end

  def upload_update_params
    params.require(:upload).permit(:name, :number_of_objective_questions, :number_of_theory_questions, :show_answers)
  end

  def regenerate_questions
    # Delete all existing questions and options for this upload
    @upload.questions.destroy_all

    # Re-run the PDF processing job to generate new questions
    PdfProcessingJob.perform_now(@upload.id)

    redirect_to uploads_path, notice: "Questions regenerated for '#{@upload.name}'."
  end

  def index
    @uploads = Upload.all.order(created_at: :desc)
  end

  def new
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(upload_params)

    if @upload.save
      # Attach the PDF file
      if params[:upload][:pdf_file]
        @upload.pdf_file.attach(params[:upload][:pdf_file])

        # Upload to Cloudinary
        if @upload.pdf_file.attached?
          # Get the file path
          file_path = ActiveStorage::Blob.service.path_for(@upload.pdf_file.key)

          # Upload to Cloudinary
          response = Cloudinary::Uploader.upload(file_path, resource_type: :auto)
          @upload.update(cloudinary_url: response["secure_url"], public_id: response["public_id"])

          # Process PDF and generate questions in background
          PdfProcessingJob.perform_now(@upload.id)
        end
      end

      redirect_to @upload, notice: "Upload was successful. Questions are being generated."
    else
      render :new
    end
  end

  def show
    @objective_questions = @upload.questions.objective.includes(:options)
    @theory_questions = @upload.questions.theory.includes(:options)
  end

  def destroy
    @upload.destroy
    redirect_to uploads_url, notice: "Upload was successfully deleted."
  end

  private

  def set_upload
    @upload = Upload.find(params[:id])
  end

  def upload_params
  params.require(:upload).permit(:name, :pdf_file, :number_of_objective_questions, :number_of_theory_questions, :show_answers)
  end
end
