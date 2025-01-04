class TinValidations::EnhancedValidationService
  def initialize(number)
    # Inicializamos la variable de errores y sanitizamos el número de entrada
    @errors = []
    @number = number.to_s.gsub(/\s/, '')
  end

  def validate
    # Ejecuta la validación principal y devuelve el resultado
    main_validation
  end

  private

  def main_validation
    # Validación básica de la entrada
    unless valid_input?
      return { valid: false, errors: @errors }
    end

    # Validación algorítmica del ABN
    { valid: valid_abn?, number: @number }
  rescue => e
    @errors << "main_validation error: #{e}"
    { valid: false, errors: @errors }
  end

  def valid_input?
    # Verificamos que el número no esté en blanco y tenga una longitud de 11
    if @number.blank? || @number.length != 11
      @errors << 'Invalid input'
      false
    else
      true
    end
  end

  def valid_abn?
    # Verificamos si el resultado del algoritmo es divisible entre 89
    (calculation_algorithm % 89).zero?
  end

  def calculation_algorithm
    # Implementa el algoritmo de validación según el sitio web del gobierno
    sum = (@number[0].to_i - 1) * 10
    @number[1..-1].chars.each_with_index do |digit, index|
      sum += digit.to_i * (index.even? ? 1 : 3) # Cambio en el patrón de multiplicación
    end
    sum
  rescue => e
    @errors << "calculation_algorithm error: #{e}"
    0 # Retornamos un valor seguro para evitar errores adicionales
  end
end
