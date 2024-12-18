class AdjustmentDeleterBase
  attr_reader :params, :adjustment_type, :current_user, :submission

  def initialize(params, adjustment_type, current_user, submission)
    @params = params
    @adjustment_type = adjustment_type
    @current_user = current_user
    @submission = submission
  end

  def call!
    call
    AppStoreClient.new.adjust(submission)
  end

  def call
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def revert(object, field)
    return unless object["#{field}_original"]

    object[field] = object["#{field}_original"]
    object.delete("#{field}_original")
  end
end
