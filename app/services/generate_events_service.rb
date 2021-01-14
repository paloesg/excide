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
      @event.tag_list.add(event_data["Job Function"])
      @event.project_list.add(event_data["Project"])
      @event.start_time = event_data["Date (DD/MM/YYYY)"]
      @event.client = Client.find_by(name: event_data["Client"])
      @event.event_type = EventType.find_by(name: event_data["Job Nature"])
      @event.number_of_hours = event_data["No. of hours"]
      @event.save!
      GenerateTimesheetAllocationService.new(@event, @user).run
    end
  end
end
