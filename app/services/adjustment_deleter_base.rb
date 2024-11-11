class AdjustmentDeleterBase
  attr_reader :params, :adjustment_type, :current_user, :submission

  def initialize(params, adjustment_type, current_user)
    @params = params
    @adjustment_type = adjustment_type
    @current_user = current_user
    @submission = submission_scope
  end

  def call!
    submission.with_lock do
      call
      AppStoreClient.new.adjust(submission)
    end
  end

  def call
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def revert(object, field, object_type)
    return unless object["#{field}_original"]

    if object[field] != object["#{field}_original"]
      create_event(field, object_type, object[field], object["#{field}_original"], object['id'])
    end

    object[field] = object["#{field}_original"]
    object.delete("#{field}_original")
  end

  def create_event(field, type, from, to_field, id_field)
    linked = { type: type, id: id_field }
    details = { field: field, from: from, to: to_field }
    ::Event::UndoEdit.build(submission:, linked:, details:, current_user:)
  end
end
