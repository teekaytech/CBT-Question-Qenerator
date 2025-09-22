
require 'rails_helper'


RSpec.describe UploadsController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http success" do
      post :create, params: { upload: { name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false } }
      expect(response).to have_http_status(:redirect).or have_http_status(:success)
    end
  end

  describe "GET #show" do
    let(:upload) { Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false) }
    it "returns http success" do
      get :show, params: { id: upload.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    let!(:upload) { Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false) }
    it "returns http success" do
      delete :destroy, params: { id: upload.id }
      expect(response).to have_http_status(:redirect).or have_http_status(:success)
    end
  end

  describe "GET #edit" do
    let(:upload) { Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false) }
    it "returns http success" do
      get :edit, params: { id: upload.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    let(:upload) { Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false) }
    it "updates the upload and redirects" do
      patch :update, params: { id: upload.id, upload: { name: 'Updated', number_of_objective_questions: 2, number_of_theory_questions: 1, show_answers: true } }
      expect(response).to redirect_to(uploads_path)
      upload.reload
      expect(upload.name).to eq('Updated')
      expect(upload.show_answers).to eq(true)
    end
    it "renders edit on failure" do
      patch :update, params: { id: upload.id, upload: { name: '', number_of_objective_questions: 0, number_of_theory_questions: 0 } }
      # Modified to not use render_template which requires rails-controller-testing gem
      expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:success)
    end
  end

  describe "PATCH #regenerate_questions" do
    let!(:upload) { Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false) }
    it "redirects to uploads_path" do
      allow(PdfProcessingJob).to receive(:perform_now)
      patch :regenerate_questions, params: { id: upload.id }
      expect(response).to redirect_to(uploads_path)
    end
  end

  describe "PATCH #toggle_show_answers" do
    let!(:upload) { Upload.create!(name: 'Test', number_of_objective_questions: 1, number_of_theory_questions: 1, show_answers: false) }
    it "toggles show_answers and redirects" do
      patch :toggle_show_answers, params: { id: upload.id }
      expect(response).to redirect_to(upload)
      upload.reload
      expect(upload.show_answers).to eq(true)
    end
  end
end
