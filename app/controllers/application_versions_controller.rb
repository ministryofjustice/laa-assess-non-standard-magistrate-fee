class ApplicationVersionsController < ApplicationController
  protect_from_forgery with: :null_session

  def update
    receiver = ReceiveApplicationMetadata.new(params[:id])

    if receiver.save(application_params, params.dig(:application, :state))
      render plain: :success
    else
      render json: { error: receiver.errors }, status: :unauthorized
    end
  end

  private

  def application_params
    params.require('application').permit(:id, :risk, :current_version)
  end
end
