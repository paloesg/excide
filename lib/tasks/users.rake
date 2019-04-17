############################################################################################################################
#                                                                                                                          #
#    Please ensure there is a database backup before running the rake task in case there is any unintended consequences.   #
#    Double check the target user accounts id (first argument) and destination user account id (second argument) to make   #
#    sure they are not mixed up.                                                                                           #
#                                                                                                                          #
############################################################################################################################

namespace :users do
  desc "Transfer all associations from target user account to destination user account and delete target user account"
  task :merge, [:target_user_id, :destination_user_id] => :environment do |task, args|
    target_user = User.find(args[:target_user_id])
    destination_user = User.find(args[:destination_user_id])

    puts "You are deleting #{target_user.email} and merging existing data into #{destination_user.email}. Are you sure? (y/n)"

    begin
      input = STDIN.gets.strip.downcase
    end until %w(y n).include?(input)

    if input != 'y'
      puts "This action has been aborted!"
      return
    end

    # Transfer clients
    clients = Client.where(user: target_user)
    count = clients.count
    clients.update_all(user_id: destination_user.id)
    puts "#{count} clients transferred from #{target_user.first_name} to #{destination_user.first_name}"

    # Transfer documents
    documents = Document.where(user: target_user)
    count = documents.count
    documents.update_all(user_id: destination_user.id)
    puts "#{count} documents transferred from #{target_user.first_name} to #{destination_user.first_name}"

    # Transfer document templates
    document_templates = DocumentTemplate.where(user: target_user)
    count = document_templates.count
    document_templates.update_all(user_id: destination_user.id)
    puts "#{count} document templates transferred from #{target_user.first_name} to #{destination_user.first_name}"

    # Transfer workflows
    workflows = Workflow.where(user: target_user)
    count = workflows.count
    workflows.update_all(user_id: destination_user.id)
    puts "#{count} workflows transferred from #{target_user.first_name} to #{destination_user.first_name}"

    # Transfer assigned tasks
    assigned_tasks = WorkflowAction.where(assigned_user: target_user)
    count = assigned_tasks.count
    assigned_tasks.update_all(assigned_user_id: destination_user.id)
    puts "#{count} assigned tasks transferred from #{target_user.first_name} to #{destination_user.first_name}"

    # Transfer completed tasks
    completed_tasks = WorkflowAction.where(completed_user: target_user)
    count = completed_tasks.count
    completed_tasks.update_all(completed_user_id: destination_user.id)
    puts "#{count} completed tasks transferred from #{target_user.first_name} to #{destination_user.first_name}"

    # Transfer user roles
    destination_user.roles << (target_user.roles - destination_user.roles)

    # Delete target user
    destroyed_user_name = target_user.first_name
    target_user.destroy!
    puts "#{destroyed_user_name} successfully deleted."
  end
end
