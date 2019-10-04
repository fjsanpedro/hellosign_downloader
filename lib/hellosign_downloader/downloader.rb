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
          file_info = get_info(signature)
          file_date = nil
          file_info.signatures.each do |signature|
            file_date = signature.signed_at || signature.last_viewed_at || signature.last_reminded_at || file_date
          end
          file_name = "#{Time.at(file_date).strftime('%Y-%m-%d %H:%M:%S')} #{file_info.title}"
          
          save_file file_name, download!(signature)
        rescue HelloSign::Error::NotFound
          puts "Signature #{signature} not found"
        end
      end
    end

    def document_info(document_ids)
      Array(document_ids).each do |signature|
        begin
          print_info(signature)
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

    def get_info(document_id)
      hello_sign_client.get_signature_request(signature_request_id: document_id)
    end

    def print_info(document_id)
      request = get_info(document_id)

      puts "Title: #{request.title}"
      puts "Subject: #{request.subject}"
      puts "Message: #{request.message}"
      puts "Signers:"
      request.signatures.each do |signature|
          puts "  #{signature.signer_name} <#{signature.signer_email_address}>"
          puts "  Last reminded: #{Time.at(signature.last_reminded_at).strftime('%Y-%m-%d %H:%M:%S')}" unless signature.last_reminded_at.nil?
          puts "  Last viewed: #{Time.at(signature.last_viewed_at).strftime('%Y-%m-%d %H:%M:%S')}" unless signature.last_viewed_at.nil?
          puts "  Signed at: #{Time.at(signature.signed_at).strftime('%Y-%m-%d %H:%M:%S')}" unless signature.signed_at.nil?
          puts "\n"
      end
    end

    def hello_sign_client
      @hello_sign_client ||= HelloSign::Client.new api_key: ENV['HELLO_SIGN_API_KEY']
    end

    def save_file(signature, content)
      file_path = destination_path(signature)
      puts "Saving document to: #{file_path}"
      open(file_path, 'wb') do |file|
        file.write(content)
      end
    end

    def destination_path(signature)
      raise StandardError, 'Destination directory does not exist' unless File.directory?(@output_dir)
      
      file_path = "#{@output_dir}/#{signature}.#{doc_format}"
      file_counter = 1;
        
      while File.exist?(file_path) do
        file_path = "#{@output_dir}/#{signature} (#{file_counter}).#{doc_format}"
      end

      file_path
    end

    def doc_format
      @doc_format ||= AVAILABLE_DOC_FORMATS.include?(@format) ? @format : DEFAULT_DOC_FORMAT
    end
  end
end
