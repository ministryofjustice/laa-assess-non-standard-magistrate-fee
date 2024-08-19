module Nsm
  class SearchForm < ::SearchForm
    def statuses
      [show_all] + %i[
        not_assigned
        in_progress
        sent_back
        granted
        part_grant
        rejected
      ].map { Option.new(_1, I18n.t("search.statuses.#{_1}")) }
    end
  end
end
