class TinValidations::ExternalValidationService

  require 'open-uri'
  require 'nokogiri'

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
    if @number.blank? || @number.length != 11
      @errors << 'Invalid input'
      return { valid: false, errors: @errors }
    end
    
    response = URI.open(@url)
    document = Nokogiri::XML(response)
    status = document.xpath("//status").text == 'Active'
    valid = document.xpath("//goodsAndServicesTax").text == 'true'
    name = document.xpath("//organisationName").text
    formatted_address = "#{document.xpath("//stateCode").text} #{document.xpath("//postcode").text}"

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
    
  rescue OpenURI::HTTPError => e
    error = if e.message == "404 Not Found"
              "Bussiness is not registered"
            elsif e.message == "500 Internal Server Error"
              "Registration API could not be reached"
            else
              e
            end
    @errors << error
    return { validation: false, errors: error }

  rescue => e
    @errors << "main_validation error: #{e}"
    return { validation: false, errors: @errors }
  end

end