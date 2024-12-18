class Api::V1::TinValidationsController < ApplicationController
  def basic
    result = TinValidations::BasicValidationService.new(params[:country], params[:number]).validate
    render json: result, status: :ok

  rescue => e
    render json: { validation: false, error: "Basic validation error: #{e}" }, status: :unprocessable_entity
  end

  def enhanced
    result = TinValidations::EnhancedValidationService.new(params[:number]).validate
    render json: result, status: :ok

  rescue => e
    render json: { validation: false, error: "Enhanced validation error: #{e}" }, status: :unprocessable_entity
  end

  def external
    result = TinValidations::ExternalValidationService.new(params[:abn]).validate
    render json: result, status: :ok

  rescue => e
    render json: { validation: false, error: "External validation error: #{e}" }, status: :unprocessable_entity
  end
  
end