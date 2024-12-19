class TinValidations::ExternalValidationService
  require 'open-uri'  # Library to open an URL from the code
  require 'nokogiri'  # Library of a Gem to manage XML formats and files

  def initialize(abn)
    @errors = []
    @number = abn.to_s.gsub(/\s/, '')
    @url = "http://localhost:8080/queryABN?abn=#{@number}"
  end

  def validate
    main_validation
  end

  private

  def main_validation
    # Basic validation for the input to avoid executing the whole validation if the input is invalid
    if @number.blank? || @number.length != 11
      @errors << 'Invalid input'
      return { valid: false, errors: @errors }
    end

    # Return the response with a hash build based in the external API validation
    return build_response

  rescue => e
    @errors << "main_validation error: #{e}"
    return { validation: false, errors: @errors }
  end

  def build_response
    response = URI.open(@url)
    # Manage easily the XML format with Nokogiri gem
    document = Nokogiri::XML(response)  
    status = document.xpath("//status").text == 'Active'
    valid = document.xpath("//goodsAndServicesTax").text == 'true'
    name = document.xpath("//organisationName").text
    formatted_address = "#{document.xpath("//stateCode").text} #{document.xpath("//postcode").text}"

    # Example of the expected output
    # {
    #   "business_registration": {
    #     "number": "10120000004",
    #     "name": "Example Company Pty Ltd",
    #     "address": "NSW 2000"
    #   },
    #   "validity": {
    #     "valid": true,
    #     "registered": true
    #   }
    # }
    return {  
      business_registration: {
        number: @number,
        name: name,
        address: formatted_address
      }, 
      validity: {
        valid: status,
        registered: valid
      }
    }

  # Manage the request errors for the URI.open(@url)
  rescue OpenURI::HTTPError => e
    error = if e.message == "404 Not Found"
              "Bussiness is not registered"
            elsif e.message == "500 Internal Server Error"
              "Registration API could not be reached"
            else
              e
            end
    @errors << error
    return { validation: false, error: error, server_status: e.message }

  rescue => e
    @errors << "build_response error: #{e}"
    return { validation: false, errors: @errors }
  end
end