class NsmApplication < BaseApplication
  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  scope :related_applications, lambda { |ufn, account_number|
    Nsm::RelatedApplications.call(ufn, account_number)
  }
end
