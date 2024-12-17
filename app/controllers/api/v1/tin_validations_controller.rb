class Api::V1::TinValidationsController < ApplicationController
  def basic    
    render json: {validation: true}, status: :ok
  end
end