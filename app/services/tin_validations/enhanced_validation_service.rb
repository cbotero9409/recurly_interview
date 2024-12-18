class TinValidations::EnhancedValidationService

  def initialize(number)
    @errors = []
    @number = number
  end

  def validate
    main_validation
  end

  private

  def main_validation
    if @number.blank?
      @errors << 'Invalid input'
      return false
    end

  rescue => e
    @errors << "main_validation error: #{e}"
    return { valid: false, errors: @errors }
  end

end