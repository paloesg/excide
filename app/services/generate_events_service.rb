class GenerateEventsService
  def initialize(file, user)
    @file = file
    @user = user
  end

  def run
    begin
      import_excel
      OpenStruct.new(success?: true, file: @file)
    rescue => e
      OpenStruct.new(success?: false, file: @file, message: e.message)
    end
  end

  private
  def import_excel
    # Import excel using roo and generates events in the timesheet
    data = Roo::Spreadsheet.open(@file).sheet("Template")
    header = data.row(8)
    data.drop(8).each do |row|
      # create hash from headers and cells
      event_data = Hash[[header, row].transpose]
      @event = Event.new
      @event.company = @user.company
      @department = @user.department
      @client = Category.create_or_find_by(name: event_data["Client"], category_type: "client", department: @department)
      @service_line = Category.create_or_find_by(name: event_data["Job Function"], category_type: "service_line", department: @department)
      @project = Category.create_or_find_by(name: event_data["Project"], category_type: "project", department: @department)
      @task = Category.create_or_find_by(name: event_data["Job Nature"], category_type: "task", department: @department)
      @event.categories << @client << @service_line << @project << @task
      @event.start_time = event_data["Date (DD/MM/YYYY)"]
      @event.number_of_hours = event_data["No. of hours"]
      @event.save!
      GenerateTimesheetAllocationService.new(@event, @user).run
    end
  end
end
