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
    data = data.parse(client: "Client", service_line: "Job Function", project: "Project", task: "Job Nature", date: "Date (DD/MM/YYYY)", hours: "No. of hours")
    CreateEventsJob.perform_later(@user, data)
  end
end
