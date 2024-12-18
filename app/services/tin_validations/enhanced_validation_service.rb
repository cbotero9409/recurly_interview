class TinValidations::EnhancedValidationService

  def initialize(number)
    @errors = []
    @number = number.to_s.gsub(/\s/, '')
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

    sum = (@number[0].to_i - 1) * 10
    other_digits = @number[1..-1].split('')
    i = 1
    other_digits.each do |digit|
      sum += (digit.to_i * i)
      i += 2 
    end

    return { valid: (sum % 89 == 0), number: @number }

  rescue => e
    @errors << "main_validation error: #{e}"
    return { validation: false, errors: @errors }
  end

end