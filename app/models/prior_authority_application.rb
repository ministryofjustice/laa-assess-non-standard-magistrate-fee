class PriorAuthorityApplication < BaseApplication
  default_scope -> { where(application_type: APPLICATION_TYPES[:prior_authority]) }

  scope :related_applications, lambda { |ufn, account_number|
    PriorAuthority::RelatedApplications.call(ufn, account_number)
  }
end
