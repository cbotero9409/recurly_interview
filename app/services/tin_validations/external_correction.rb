require 'open-uri'
require 'nokogiri'

class TinValidations::ExternalValidationService
  VALIDATION_URL = "http://localhost:8080/queryABN?abn="

  def initialize(abn)
    @errors = []
    @number = abn.to_s.gsub(/\s/, '')
    @url = "#{VALIDATION_URL}#{@number}"
  end

  def validate
    return { valid: false, errors: @errors } unless valid_input?

    build_response
  rescue StandardError => e
    handle_error("validate", e)
  end

  private

  def valid_input?
    if @number.blank? || @number.length != 11
      @errors << 'Invalid input'
      return false
    end
    true
  end

  def build_response
    response = URI.open(@url)
    document = Nokogiri::XML(response)

    {
      business_registration: parse_business_registration(document),
      validity: parse_validity(document)
    }
  rescue OpenURI::HTTPError => e
    handle_http_error(e)
  rescue StandardError => e
    handle_error("build_response", e)
  end

  def parse_business_registration(document)
    {
      number: @number,
      name: document.xpath("//organisationName").text,
      address: format_address(document)
    }
  end

  def parse_validity(document)
    {
      valid: document.xpath("//status").text == 'Active',
      registered: document.xpath("//goodsAndServicesTax").text == 'true'
    }
  end

  def format_address(document)
    "#{document.xpath('//stateCode').text} #{document.xpath('//postcode').text}"
  end

  def handle_http_error(error)
    error_message = case error.message
                    when "404 Not Found"
                      "Business is not registered"
                    when "500 Internal Server Error"
                      "Registration API could not be reached"
                    else
                      error.message
                    end
    @errors << error_message
    { validation: false, error: error_message, server_status: error.message }
  end

  def handle_error(method, error)
    @errors << "#{method} error: #{error.message}"
    { validation: false, errors: @errors }
  end
end
