class TinValidations::BasicValidationService
  COUNTRIES = %w(AU CA IN)
  FORMATS = { AU: /^(\d{9}|\d{11})$/, CA: /^\d{9}(RT0001)?$/, IN: /^\d{2}[0-9|A-Z]{10}\d[A-Z]\d$/ }
  # If add many more countries we need to create a table and save formats in a db 

  def initialize(country, number)
    @errors = []
    @country = country.upcase
    @number = number.to_s.gsub(/\s/, '')
  end

  def validate
    main_validation
  end

  private

  def main_validation
    # Basic validation for the inputs to avoid executing the whole validation if the inputs are invalid
    if !COUNTRIES.include?(@country) || @number.blank?
      @errors << 'Invalid inputs'
      return { valid: false, errors: @errors }
    end
    
    # Checks valid number format depending on the country
    return { valid: false, errors: @errors } unless valid_number?

    # If pass the validation, here puts the number output in the right format
    case @country
    when 'AU' then australian_format
    when 'CA' then canadian_format
    when 'IN' then return { valid: true, tin_type: 'in_gst', formatted_tin: @number }
    end

  rescue => e
    @errors << "main_validation error: #{e}"
    return { valid: false, errors: @errors }
  end

  # This method compares the number input with its country format TIN
  def valid_number?
    unless @number.match?(FORMATS[@country.to_sym])
      @errors << "Invalid format number input"
      return false
    end   

    return true

  rescue => e
    @errors << "valid_number error: #{e}"
    return { valid: false }
  end

  # Methods to format the number output for every country
  # Australian format
  def australian_format
    # Example: Number: '101200000'; responds with '101 200 000'
    if @number.length == 9
      @number = "#{@number[0..2]} #{@number[3..5]} #{@number[6..8]}"
      tin_type = 'au_acn'
    # Example: Number: '10120000004'; responds with '10 120 000 004'
    elsif @number.length == 11
      @number = "#{@number[0..1]} #{@number[2..4]} #{@number[5..7]} #{@number[8..10]}"
      tin_type = 'au_abn'
    end
    return { valid: true, tin_type: tin_type, formatted_tin: @number }

  rescue => e
    @errors << "australian_format error: #{e}"
    return { valid: false, errors: @errors }
  end

  # Canadian format
  # If number length is 9 characters it adds 'RT0001' to the end of the number, else the format remains the same
  # Example: Number: '123456789', responds with '123456789RT0001'
  # Example: Number: '123456789RT0001', responds with '123456789RT0001'
  def canadian_format
    @number += 'RT0001' if @number.length == 9 
    return { valid: true, tin_type: 'ca_gst', formatted_tin: @number }

  rescue => e
    @errors << "canadian_format error: #{e}"
    return { valid: false, errors: @errors }
  end
end