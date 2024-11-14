class PriorAuthorityApplicationPolicy < ApplicationPolicy
  def unassign?
    assessable? && record.assigned_user_id.present? && !user.viewer?
  end

  def self_assign?
    assign? && assessable? && record.assigned_user_id.nil?
  end

  def update?
    assessable? && record.assigned_user_id == user.id && !user.viewer?
  end

  def assign?
    !user.viewer?
  end

  def index?
    true
  end

  def show?
    true
  end

  private

  def assessable?
    record.state.in?(PriorAuthorityApplication::ASSESSABLE_STATES)
  end
end
