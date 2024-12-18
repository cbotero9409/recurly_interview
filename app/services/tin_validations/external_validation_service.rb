class TinValidations::ExternalValidationService

  def initialize(abn)
    @errors = []
    @number = abn.to_s.gsub(/\s/, '')
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

    return { valid: true, number: @number }

  rescue => e
    @errors << "main_validation error: #{e}"
    return { validation: false, errors: @errors }
  end

end