class ClaimPolicy < ApplicationPolicy
  def update?
    !record.closed? && record.assigned_to?(user)
  end

  def unassign?
    !record.closed? && record.assignments.any? && !user.viewer?
  end

  def self_assign?
    assign? && !record.closed? && record.assignments.none?
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
end
