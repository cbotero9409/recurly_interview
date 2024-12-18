class TinValidations::BasicValidationService
  COUNTRIES = %w(AU CA IN)
  FORMATS = { AU: /^(\d{9}|\d{11})$/, CA: /^\d{9}(RT0001)?$/, IN: /^\d{2}[0-9|A-Z]{10}\d[A-Z]\d$/ }
  # If add many more countries we need to create a table and save this data in a db 

  def initialize(country, number)
    @errors = []
    @country = country.upcase
    @number = number.gsub(/\s/, '')
  end

  def validate
    main_validation
  end

  private

  def main_validation
    if !COUNTRIES.include?(@country) || @number.blank?
      @errors << 'Invalid inputs'
      return false
    end
    
    return { valid: false, errors: @errors } unless valid_number?

    case @country
    when 'AU' then australian_format
    when 'CA' then canadian_format
    when 'IN' then indian_format
    end

  rescue => e
    @errors << "main_validation error: #{e}"
    return { valid: false, errors: @errors }
  end

  def australian_format
    if @number.length == 9
      @number = "#{@number[0..2]} #{@number[3..5]} #{@number[6..8]}"
      tin_type = 'au_acn'
    elsif @number.length == 11
      @number = "#{@number[0..1]} #{@number[2..4]} #{@number[5..7]} #{@number[8..10]}"
      tin_type = 'au_abn'
    end
    return { valid: true, tin_type: tin_type, formatted_tin: @number }

  rescue => e
    @errors << "australian_format error: #{e}"
    return { valid: false, errors: @errors }
  end

  def canadian_format
    @number += 'RT0001' if @number.length == 9 
    return { valid: true, tin_type: 'ca_gst', formatted_tin: @number }

  rescue => e
    @errors << "canadian_format error: #{e}"
    return { valid: false, errors: @errors }
  end

  def indian_format
    return { valid: true, tin_type: 'in_gst', formatted_tin: @number }

  rescue => e
    @errors << "indian_format error: #{e}"
    return { valid: false, errors: @errors }
  end

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
end