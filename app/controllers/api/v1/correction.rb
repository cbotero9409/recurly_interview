class Api::V1::TinValidationsController < ApplicationController
  before_action :validate_params, only: [:basic, :enhanced, :external]

  def basic
    result = TinValidations::BasicValidationService.new(params[:country], params[:number]).validate
    render json: result, status: :ok
  rescue => e
    render_error("Basic validation error: #{e}")
  end

  def enhanced
    result = TinValidations::EnhancedValidationService.new(params[:number]).validate
    render json: result, status: :ok
  rescue => e
    render_error("Enhanced validation error: #{e}")
  end

  def external
    result = TinValidations::ExternalValidationService.new(params[:abn]).validate
    render json: result, status: :ok
  rescue => e
    render_error("External validation error: #{e}")
  end

  private

  def validate_params
    required_params = case action_name
                      when 'basic'
                        %i[country number]
                      when 'enhanced'
                        %i[number]
                      when 'external'
                        %i[abn]
                      end

    missing_params = required_params.select { |param| params[param].blank? }
    render_error("Missing parameters: #{missing_params.join(', ')}") if missing_params.any?
  end

  def render_error(message)
    render json: { validation: false, error: message }, status: :unprocessable_entity
  end
end
