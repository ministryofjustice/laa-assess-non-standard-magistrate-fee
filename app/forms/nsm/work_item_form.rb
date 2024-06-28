module Nsm
  class WorkItemForm < BaseAdjustmentForm
    LINKED_CLASS = V1::WorkItem
    UPLIFT_PROVIDED = 'no'.freeze
    UPLIFT_RESET = 'yes'.freeze

    CHANGE_WORK_TYPE_OPTION = Struct.new(:value, :label, :hint)
    ATTENDANCE_WITH_COUNSEL = { value: 'attendance_with_counsel', en: 'Attendance with counsel' }.freeze

    attribute :id, :string
    attribute :uplift, :string
    attribute :time_spent, :time_period
    attribute :work_type, :translated
    attribute :change_work_type, :boolean
    attribute :attendance_with_counsel_pricing, :decimal

    validates :uplift, inclusion: { in: [UPLIFT_PROVIDED, UPLIFT_RESET] }, if: -> { item.uplift? }
    validates :change_work_type, inclusion: { in: [true, false] }, if: :offer_to_change_work_type?
    validates :time_spent, allow_nil: true, time_period: { allow_zero: true }

    # overwrite uplift setter to allow value to be passed as either string (form)
    # or integer (initial setup) value
    def uplift=(val)
      case val
      when String then super
      when nil then nil
      else
        super(val.positive? ? 'no' : 'yes')
      end
    end

    def save
      return false unless valid?

      Claim.transaction do
        process_field(value: time_spent.to_i, field: 'time_spent') if time_spent.present?
        process_field(value: new_uplift, field: 'uplift') if item.uplift?
        if change_work_type
          process_field(value: ATTENDANCE_WITH_COUNSEL, field: 'work_type')
          process_field(value: attendance_with_counsel_pricing, field: 'pricing')
        end

        claim.save
      end

      true
    end

    def offer_to_change_work_type?
      work_type&.value == 'attendance_without_counsel'
    end

    def change_work_type_options
      [
        CHANGE_WORK_TYPE_OPTION.new(
          value: true,
          label: I18n.t('nsm.work_items.edit.change_work_type.yes'),
          hint: I18n.t('nsm.work_items.edit.change_work_type.yes_hint'),
        ),
        CHANGE_WORK_TYPE_OPTION.new(
          value: false,
          label: I18n.t('nsm.work_items.edit.change_work_type.no'),
          hint: nil,
        ),
      ]
    end

    private

    def no_change_field
      return super if item.uplift?

      :time_spent
    end

    def selected_record
      @selected_record ||= claim.data['work_items'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def new_uplift
      uplift == 'yes' ? 0 : item.original_uplift
    end

    def data_has_changed?
      time_spent != item.time_spent ||
        (offer_to_change_work_type? && change_work_type != false) ||
        (item.uplift? && item.uplift.zero? != (uplift == UPLIFT_RESET))
    end
  end
end
