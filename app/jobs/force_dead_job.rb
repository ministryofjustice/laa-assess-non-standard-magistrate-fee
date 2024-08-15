class ForceDeadJob < ApplicationJob
  sidekiq_options retry: 0

  def perform
    raise StandardError.new "Fail job"
  end
end
