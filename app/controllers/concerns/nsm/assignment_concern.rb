module Nsm
  module AssignmentConcern
    extend ActiveSupport::Concern

    def assign(claim, comment: nil, tell_app_store: true)
      AppStoreClient.new.assign(claim, current_user) if tell_app_store
      ::Event::Assignment.build(submission: claim, current_user: current_user, comment: comment)
    end
  end
end
