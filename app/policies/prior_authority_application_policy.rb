class PriorAuthorityApplicationPolicy < ApplicationPolicy
  def unassign?
    assessable? && record.assignments.any? && !user.viewer?
  end

  def self_assign?
    assign? && assessable? && record.assignments.none?
  end

  def update?
    assessable? && record.assignments.find_by(user:) && !user.viewer?
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
