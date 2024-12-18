class Api::V1::TinValidationsController < ApplicationController
  def basic
    result = TinValidations::BasicValidationService.new(params[:country], params[:number]).validate
    if result.present?
      render json: result, status: :ok
    else      
      render json: { validation: false, errors: @errors }, status: :unprocessable_entity
    end

  rescue => e
    @errors << "Basic validation error: #{e}"
    render json: { validation: false, errors: @errors }, status: :unprocessable_entity
  end

  def enhanced
    result = TinValidations::EnhancedValidationService.new(params[:number]).validate
    if result.present?
      render json: result, status: :ok
    else      
      render json: { validation: false, errors: @errors }, status: :unprocessable_entity
    end

  rescue => e
    @errors << "Enhanced validation error: #{e}"
    render json: { validation: false, errors: @errors }, status: :unprocessable_entity
  end
  
end