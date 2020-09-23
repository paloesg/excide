class SymphonyPolicy < Struct.new(:user, :symphony)
  def index?
    user.company.products.include? 'symphony'
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def tasks?
    index?
  end

  def activity_history?
    index?
  end

  def add_tasks_to_timesheet?
    index?
  end
end