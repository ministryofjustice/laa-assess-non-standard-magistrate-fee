class ClaimPolicy < ApplicationPolicy
  def update?
    !record.closed? && record.assigned_user_id == user.id
  end

  def unassign?
    !record.closed? && record.assigned_user_id.present? && !user.viewer?
  end

  def self_assign?
    assign? && !record.closed? && record.assigned_user_id.nil?
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
