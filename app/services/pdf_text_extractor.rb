class PdfTextExtractor
  def self.extract_text(file_path)
    return "" unless File.exist?(file_path)

    text = ""
    begin
      PDF::Reader.open(file_path) do |reader|
        reader.pages.each do |page|
          text += page.text
        end
      end
    rescue => e
      Rails.logger.error "PDF Text Extraction Error: #{e.message}"
    end

    text
  end
end
