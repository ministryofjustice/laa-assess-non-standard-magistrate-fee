class PriorAuthorityApplicationPolicy < ApplicationPolicy
  def unassign?
    assessable? && record.assigned_user.present? && !user.viewer?
  end

  def self_assign?
    assign? && assessable? && record.assigned_user.nil?
  end

  def update?
    assessable? && record.assigned_user == user && !user.viewer?
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
