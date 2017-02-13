class HelloSignDownloader
  class Downloader
    DEFAULT_DOC_FORMAT = 'pdf'
    AVAILABLE_DOC_FORMATS = ['zip', 'pdf']

    def initialize(signature_uuids, format: DEFAULT_DOC_FORMAT)
      @signature_uuids = Array(signature_uuids)
      @format = doc_format(format)
    end

    def download
      client = HelloSign::Client.new api_key: ENV['HELLO_SIGN_API_KEY']

      @signature_uuids.each do |signature|
        begin
          file_bin = client.signature_request_files signature_request_id: signature,
                                                    file_type: @format
          save_file signature, file_bin
        rescue HelloSign::Error::NotFound
          puts "Signature #{signature} not found"
        end
      end
    end

    private

    def save_file(signature, content)
      open("tmp/#{signature}.pdf", 'wb') do |file|
        file.write(content)
      end
    end

    def doc_format(current_format)
      if current_format.empty? || !AVAILABLE_DOC_FORMATS.include?(current_format.downcase)
        DEFAULT_DOC_FORMAT
      else
        current_format
      end
    end
  end
end
