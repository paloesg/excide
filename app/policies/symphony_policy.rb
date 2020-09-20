class SymphonyPolicy < ApplicationPolicy
  def show?
    user.company.products.include? 'Symphony'
  end

  def new?
    show?
  end

  def create?
    show?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def tasks?
    show?
  end

  def activity_history?
    show?
  end

  def add_tasks_to_timesheet?
    show?
  end
end