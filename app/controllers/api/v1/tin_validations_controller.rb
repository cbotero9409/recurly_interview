class Api::V1::TinValidationsController < ApplicationController
  def basic
    if params[:tin_validation][:input].present?
      render json: { validation: true }, status: :ok
    else
      render json: { validation: false, status: 'failed' }, status: :not_acceptable
    end
  end
end