module Nsm
  module ControllerParams
    class Claims < Nsm::ControllerParams::Base
      attribute :id, :string
      attribute :sort_by, :string
      attribute :sort_direction, :string
      attribute :page, :integer

      validates :sort_by, inclusion: { in: %w(laa_reference firm_name client_name last_updated status_with_assignment) }, allow_nil: true
      validates :sort_direction, inclusion: { in: %w(ascending descending) }, allow_nil: true
      validates :page, numericality: { greater_than: 0 }, allow_nil: true
    end
  end
end
