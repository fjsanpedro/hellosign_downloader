require 'command_line_reporter'

class HelloSignDownloader
  class Reporter
    include CommandLineReporter

    def initialize(documents)
      @documents = documents
    end

    def run
      table :border => true do
        row do
          column 'Document ID', width: 40, bold: true, align: 'center'
          column 'Complete', width: 30, align: 'center'
          column 'Declined', width: 15, align: 'center'
          column 'Has Errors', width: 15, align: 'center'
        end
        if @documents.any?
          @documents.each do |d|
            row do
              column d.signature_request_id
              column d.is_complete
              column d.is_declined
              column d.has_error
            end
          end
        else
          row do
            column 'No data available'
          end
        end
      end
    end
  end
end
