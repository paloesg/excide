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
    puts "#{count} clients transferred from #{target_user.email} to #{destination_user.email}"

    # Transfer documents
    documents = Document.where(user: target_user)
    count = documents.count
    documents.update_all(user_id: destination_user.id)
    puts "#{count} documents transferred from #{target_user.email} to #{destination_user.email}"

    # Transfer document templates
    document_templates = DocumentTemplate.where(user: target_user)
    count = document_templates.count
    document_templates.update_all(user_id: destination_user.id)
    puts "#{count} document templates transferred from #{target_user.email} to #{destination_user.email}"

    # Transfer workflows
    workflows = Workflow.where(user: target_user)
    count = workflows.count
    workflows.update_all(user_id: destination_user.id)
    puts "#{count} workflows transferred from #{target_user.email} to #{destination_user.email}"

    # Transfer assigned tasks
    assigned_tasks = WorkflowAction.where(assigned_user: target_user)
    count = assigned_tasks.count
    assigned_tasks.update_all(assigned_user_id: destination_user.id)
    puts "#{count} assigned tasks transferred from #{target_user.email} to #{destination_user.email}"

    # Transfer completed tasks
    completed_tasks = WorkflowAction.where(completed_user: target_user)
    count = completed_tasks.count
    completed_tasks.update_all(completed_user_id: destination_user.id)
    puts "#{count} completed tasks transferred from #{target_user.email} to #{destination_user.email}"

    # Transfer user roles
    destination_user.roles << (target_user.roles - destination_user.roles)

    # Delete target user
    destroyed_user_name = target_user.email
    target_user.destroy!
    puts "#{destroyed_user_name} successfully deleted."
  end

  desc "Remap user roles in conductor"
  task remap_roles_in_conductor: :environment do
    # Change users role contractor_in_charge to be consultant
    roles_contractor_in_charge = Role.where(name: "contractor_in_charge")
    roles_contractor_in_charge.each do |role|
      role.users.each do |user|
        user.add_role :consultant, role.resource
        user.remove_role role.name, role.resource
      end
    end

    # Change users role contractor to be associate
    roles_contractor = Role.where(name: "contractor")
    roles_contractor.each do |role|
      role.users.each do |user|
        user.add_role :associate, role.resource
        user.remove_role role.name, role.resource
      end
    end

    # Change users role event_creator/event_owner/manpower_allocator to be stafer
    roles_creator_owner_manpower = Role.where(name: ["event_owner", "event_owner", "manpower_allocator", "Manpower Allocator"])
    roles_creator_owner_manpower.each do |role|
      role.users.each do |user|
        user.add_role :staffer, role.resource
        user.remove_role role.name, role.resource
      end
    end
  end
end
