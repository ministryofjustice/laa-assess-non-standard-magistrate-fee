class ApplicationVersionsController < ApplicationVersionsController
  def update
    claim = Claim.find_or_initialize_by(id: params[:id])
    claim.assign_attributes(application_params)
    claim.received_on ||= Date.tiday
    # think about what should happen with state? maybe don't care for now
    claim.state ||= params.dig(:application, :state)

    if claim.save
      if claim.saved_change_to_current_version?
        # we don't need to invalidate as everything is tied to current_version
        PullLatestVersionData.perform_later(claim)
      end

      render head: :ok
    else
      render json: { error: :here }, status: 401
    end
  end

  private

  def application_params
    params.require('application').permit(:id, :risk, :current_version)
  end
end