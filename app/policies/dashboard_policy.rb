class DashboardPolicy < ApplicationPolicy
  def show?
    user.supervisor?
  end
end
