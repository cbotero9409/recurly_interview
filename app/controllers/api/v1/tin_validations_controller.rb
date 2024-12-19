class Api::V1::TinValidationsController < ApplicationController
  # Basic "manual" validation, it expects two params, example: { country: 'AU', number: '10 120 000 004' }
  def basic
    result = TinValidations::BasicValidationService.new(params[:country], params[:number]).validate
    render json: result, status: :ok

  rescue => e
    render json: { validation: false, error: "Basic validation error: #{e}" }, status: :unprocessable_entity
  end

  # Enhanced validation, with algorithm check, just for ABN
  # It expects one param, example: { number: 10000000000 }
  def enhanced
    result = TinValidations::EnhancedValidationService.new(params[:number]).validate
    render json: result, status: :ok

  rescue => e
    render json: { validation: false, error: "Enhanced validation error: #{e}" }, status: :unprocessable_entity
  end

  # ABN validation using an external validation API
  # It expects one param, example: { abn: 10120000004 }
  def external    
    result = TinValidations::ExternalValidationService.new(params[:abn]).validate
    render json: result, status: :ok

  rescue => e
    render json: { validation: false, error: "External validation error: #{e}" }, status: :unprocessable_entity
  end  
end