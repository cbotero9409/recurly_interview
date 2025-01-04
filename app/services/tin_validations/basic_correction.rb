class TinValidations::BasicValidationService
  # List of supported countries
  COUNTRIES = %w(AU CA IN).freeze

  # Regular expressions for each country's TIN format
  FORMATS = {
    AU: /^\d{9}$|^\d{11}$/,
    CA: /^\d{9}(RT0001)?$/,
    IN: /^\d{2}[0-9A-Z]{10}\d[A-Z]\d$/
  }.freeze

  def initialize(country, number)
    # Initialize and sanitize inputs
    @errors = []
    @country = country.to_s.upcase.strip
    @number = number.to_s.gsub(/\s/, '')
  end

  def validate
    # Validate inputs and return result or formatted TIN
    return { valid: false, errors: @errors } unless valid_inputs?

    case @country
    when 'AU' then format_australian # Australian TIN formatting
    when 'CA' then format_canadian   # Canadian TIN formatting
    when 'IN' then format_indian     # Indian TIN formatting
    else
      @errors << 'Unsupported country'
      { valid: false, errors: @errors }
    end
  end

  private

  def valid_inputs?
    # Check if country is supported
    unless COUNTRIES.include?(@country)
      @errors << 'Invalid country'
      return false
    end

    # Check if TIN matches the expected format
    unless @number.match?(FORMATS[@country.to_sym])
      @errors << 'Invalid number format'
      return false
    end

    true
  end

  def format_australian
    # Format Australian TIN based on length
    formatted_number = if @number.length == 9
                         @number.gsub(/(\d{3})(\d{3})(\d{3})/, '\1 \2 \3')
                       else
                         @number.gsub(/(\d{2})(\d{3})(\d{3})(\d{3})/, '\1 \2 \3 \4')
                       end
    { valid: true, tin_type: tin_type_au, formatted_tin: formatted_number }
  end

  def format_canadian
    # Add RT0001 to Canadian TIN if necessary
    formatted_number = @number.length == 9 ? "#{@number}RT0001" : @number
    { valid: true, tin_type: 'ca_gst', formatted_tin: formatted_number }
  end

  def format_indian
    # Return Indian TIN as is
    { valid: true, tin_type: 'in_gst', formatted_tin: @number }
  end

  def tin_type_au
    # Determine Australian TIN type based on length
    @number.length == 9 ? 'au_acn' : 'au_abn'
  end
end
