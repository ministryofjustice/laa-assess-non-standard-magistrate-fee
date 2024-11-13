class ClaimPolicy < ApplicationPolicy
  def update?
    !record.closed? && record.assigned_user == user
  end

  def unassign?
    !record.closed? && record.assigned_user.present? && !user.viewer?
  end

  def self_assign?
    assign? && !record.closed? && record.assigned_user.nil?
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
