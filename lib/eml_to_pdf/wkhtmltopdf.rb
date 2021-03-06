require 'timeout'

module EmlToPdf
  class Wkhtmltopdf
    class ConversionError < StandardError; end
    class ConversionTimeoutError < StandardError
      def message
        "Failed to convert within the configured timeout. Use EmlToPdf.configure to increase the timeout if needed."
      end
    end

    def self.convert(input, output_path)
      Timeout.timeout(EmlToPdf.configuration.timeout, ConversionTimeoutError) do
        IO.popen("#{EmlToPdf.configuration.wkhtmltopdf} --encoding utf-8 --footer-center [page] --footer-spacing 2.5 --quiet - #{output_path} 2>&1", "r+") do |pipe|
          pipe.puts(input)
          pipe.close_write
          output = pipe.readlines.join
          pipe.close
          unless $?.success? || output.include?('ContentNotFoundError')
            raise ConversionError, output
          end
        end
      end
    end
  end
end
