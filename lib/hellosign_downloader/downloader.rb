class HelloSignDownloader
  class Downloader

    DEFAULT_DOC_FORMAT = 'pdf'
    AVAILABLE_DOC_FORMATS = ['zip', 'pdf']

    def initialize(format: DEFAULT_DOC_FORMAT, output_dir: nil)
      @format = format&.downcase
      @output_dir = output_dir || Dir.pwd
    end

    def document_download(document_ids)
      Array(document_ids).each do |signature|
        begin
          save_file signature, download!(signature)
        rescue HelloSign::Error::NotFound
          puts "Signature #{signature} not found"
        end
      end
    end

    def query_download(query)
      document_download(query!(query).map(&:signature_request_id))
    end

    def query_documents(query)
      Reporter.new(query!(query)).run
    end



    private

    def query!(query)
      hello_sign_client.get_signature_requests(query: query.compact.join(' '))
    end

    def download!(document_id)
      hello_sign_client.signature_request_files signature_request_id: document_id,
                                                file_type: doc_format
    end

    def hello_sign_client
      @hello_sign_client ||= HelloSign::Client.new api_key: ENV['HELLO_SIGN_API_KEY']
    end

    def save_file(signature, content)
      puts "Saving Document with ID: #{signature}"
      open(destination_path(signature), 'wb') do |file|
        file.write(content)
      end
    end

    def destination_path(signature)
      raise StandardError, 'Destination directory does not exist' unless File.directory?(@output_dir)
      "#{@output_dir}/#{signature}.#{doc_format}"
    end

    def doc_format
      @doc_format ||= AVAILABLE_DOC_FORMATS.include?(@format) ? @format : DEFAULT_DOC_FORMAT
    end
  end
end
