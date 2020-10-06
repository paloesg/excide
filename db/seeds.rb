# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
gobbler = Company.create(name: 'Gobbler', connect_xero: false, products: ['symphony'])
global_admin = User.create(email: 'hschin@gmail.com', password: 'password', first_name: 'Admin', last_name: 'Global', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
global_admin.add_role :superadmin
admin = User.create(email: 'admin@gobbler.com', password: 'password', first_name: 'Admin', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
admin.add_role :admin, gobbler
sales = User.create(email: 'sales@gobbler.com', password: 'password', first_name: 'Sales', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
sales.add_role :sales, gobbler
sales_support = User.create(email: 'sales_support@gobbler.com', password: 'password', first_name: 'Sales Support', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
sales_support.add_role :sales_support, gobbler
procurement = User.create(email: 'procurement@gobbler.com', password: 'password', first_name: 'Procurement', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
procurement.add_role :procurement, gobbler
finance = User.create(email: 'finance@gobbler.com', password: 'password', first_name: 'Finance', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
finance.add_role :finance, gobbler
management = User.create(email: 'management@gobbler.com', password: 'password', first_name: 'Management', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
management.add_role :management, gobbler
vp_sales = User.create(email: 'vp_sales@gobbler.com', password: 'password', first_name: 'VP Sales', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
vp_sales.add_role :vp_sales, gobbler
associate = User.create(email: 'associate@gobbler.com', password: 'password', first_name: 'Associate', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
associate.add_role :associate, gobbler
consultant = User.create(email: 'consultant@gobbler.com', password: 'password', first_name: 'Consultant', last_name: 'Gobbler', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
consultant.add_role :consultant, gobbler
associate_in_charge = User.create(email: 'associate@gobbler.com', password: 'password', first_name: 'Associate', last_name: 'Guy', contact_number: "12341234", company: gobbler, confirmed_at: Time.now)
associate_in_charge.add_role :associate, gobbler
shared_service = User.create(email: 'shared_service@gobbler.com', password: 'password', first_name: 'Shared', last_name: 'Service', contact_number: '12341234', company: gobbler, confirmed_at: Time.now)
shared_service.add_role :shared_service, gobbler

# Create template
template_1 = Template.create(title: 'Template 1', company: gobbler, template_pattern: 0)

section = Section.create(section_name: "paloe", position: 1, template: template_1)

task_list = [
  ['Calculate the amount of expenditure', 1, 6, false, 1, 1, Section.find(1)],
  ['Calculate the payroll of employees', 2, 4, false, 1, 1, Section.find(1)],
  ['File all the papers since 1989', 3, 1, true, 2, 2, Section.find(1)],
  ['Shredding the papers', 4, 1, true, 2, 2, Section.find(1)],
  ['Do powerpoint slides for presentation', 4, 12, false, 3, 3, Section.find(1)],
  ['Communicate with project group friend for some correction', 5, 1, false, 3, 3, Section.find(1)],
  ['Check the balance sheet of the accountants', 6, 7, false, 1, 0, Section.find(1)],
  ['Get approval signature from the finance manager', 7, 1, true, 1, 2, Section.find(1)],
  ['Upload accounting data into company"s excel sheet', 8, 5, false, 1, 6, Section.find(1)],
  ['Get the supervisor of the finance department to sign important documents', 9, 2, false, 1, 2, Section.find(1)],
  ['Enter the data from the papers onto the excel sheet', 10, 3, true, 2, 6, Section.find(1)],
  ['Allocate project work to team members', 11, 1, false, 3, 0, Section.find(1)],
  ['Upload the main HTML document needed for the project', 12, 6, true, 3, 1, Section.find(1)],
  ['Upload profile pictures of the team members', 13, 10, false, 3, 5, Section.find(1)],
  ['Fold paper planes with the excess paper', 14, 4, false, 2, 0, Section.find(1)]
  ]

task_list.each do |instruct, pos, completion, remind, role, task, sect|
  Task.create(instructions: instruct, position: pos, days_to_complete: completion, set_reminder: remind, role_id: role, task_type: task, section: sect)
end

workflow_1 = Workflow.create(user_id: admin.id, company_id: gobbler.id, template_id: template_1.id, completed: false, identifier: 'W_flow1', workflowable_id: 1, workflowable_type: "Client", remarks: "BLAH")


# Create document template
document_template_1 = DocumentTemplate.create(title: 'Doc template 1', description: 'Describe the template of the first document', file_url: 'http://www.doc_sksij.com', template_id: 2, user_id: 1, template: template_1)

# Create clients
client_list = [
  ['Harry Lee', 'HL', 1, 1],
  ['Emma Taylor', 'ET', 3, 1],
  ['Ron West', 'RW', 6, 1],
  ['Jon Lau', 'JL92', 2, 1],
  ['Henry Labor', 'HLBR', 1, 1],
  ['Barney the dinosaur', 'Hug', 2, 1],
  ['Ichigo Kushid', 'Jap', 5, 1],
  ['Pinky', 'Colorful', 4, 1]
]

client_list.each do |name, identifier, user_id, comp_id|
  Client.create(name: name, identifier: identifier, user_id: user_id, company_id: comp_id)
end

reminders = [
  [20180629, false, 1, 2, 5, 1,'Reminder for task 1','please remember to do task 1', 3, true, false, true, Task.find(1)],
  [20180702, true, 1, 1, 5, 1, 'Reminder for task 2', 'Please do task 2 by the next reminder', 4, false, true, false, Task.find(2)]
]

reminders.each do |next_remind, repeat, freq_value, freq_unit, user_id, comp_id, title, content, taskid, email, sms, slack, task|
  Reminder.create(next_reminder: next_remind, repeat: repeat, freq_value: freq_value, freq_unit: freq_unit, user_id: user_id, company_id: comp_id, title: title, content:content, task_id: taskid, email: email, sms: sms, slack: slack, task: task)
end
