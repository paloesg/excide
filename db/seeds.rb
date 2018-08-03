# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
gobbler = Company.create(name: 'Gobbler')
admin = User.create(email: 'admin@gobbler.com', password: 'password', first_name: 'Admin', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
admin.add_role :admin, gobbler
sales = User.create(email: 'sales@gobbler.com', password: 'password', first_name: 'Sales', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
sales.add_role :sales, gobbler
sales_support = User.create(email: 'sales_support@gobbler.com', password: 'password', first_name: 'Sales Support', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
sales_support.add_role :sales_support, gobbler
procurement = User.create(email: 'procurement@gobbler.com', password: 'password', first_name: 'Procurement', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
procurement.add_role :procurement, gobbler
finance = User.create(email: 'finance@gobbler.com', password: 'password', first_name: 'Finance', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
finance.add_role :finance, gobbler
management = User.create(email: 'management@gobbler.com', password: 'password', first_name: 'Management', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
management.add_role :management, gobbler
vp_sales = User.create(email: 'vp_sales@gobbler.com', password: 'password', first_name: 'VP Sales', last_name: 'Gobbler', contact_number: '12341234', company: gobbler)
vp_sales.add_role :vp_sales, gobbler

# Create template
template_1 = Template.create(title: 'Template 1', company: gobbler)

sections = [['Section 1', 'Finance', 1, template_1], ['Section 2', 'Paper Work', 2, template_1], ['Section 3', 'Project Work', 3, template_1]]

sections.each do |u_name, d_name, pos, template|
  Section.create(unique_name: u_name, display_name: d_name, position: pos, template: template)
end

task_list = [
  ['Calculate the amount of expenditure', 1, 6, false, 1, 1, Section.find(1)],
  ['Calculate the payroll of employees', 2, 4, false, 1, 1, Section.find(1)],
  ['File all the papers since 1989', 3, 1, true, 2, 2, Section.find(2)],
  ['Shredding the papers', 4, 1, true, 2, 2, Section.find(2)],
  ['Do powerpoint slides for presentation', 4, 12, false, 3, 3, Section.find(3)],
  ['Communicate with project group friend for some correction', 5, 1, false, 3, 3, Section.find(3)],
  ['Check the balance sheet of the accountants', 6, 7, false, 1, 0, Section.find(1)],
  ['Get approval signature from the finance manager', 7, 1, true, 1, 2, Section.find(1)],
  ['Upload accounting data into company"s excel sheet', 8, 5, false, 1, 6, Section.find(1)],
  ['Get the supervisor of the finance department to sign important documents', 9, 2, false, 1, 2, Section.find(2)],
  ['Enter the data from the papers onto the excel sheet', 10, 3, true, 2, 6, Section.find(3)],
  ['Allocate project work to team members', 11, 1, false, 3, 0, Section.find(3)],
  ['Upload the main HTML document needed for the project', 12, 6, true, 3, 1, Section.find(2)],
  ['Upload profile pictures of the team members', 13, 10, false, 3, 5, Section.find(3)],
  ['Fold paper planes with the excess paper', 14, 4, false, 2, 0, Section.find(2)]
  ]

task_list.each do |instruct, pos, completion, remind, role, task, sect|
  Task.create(instructions: instruct, position: pos, days_to_complete: completion, set_reminder: remind, role_id: role, task_type: task, section: sect)
end

workflows = [
  [1, 1, 1, false, 'W_flow1', 1, "Client", "EFGHIJ", template_1],
  [2, 1, 1, false, 'W_flow2', 1, "Client", "sdjdf", template_1],
  [3, 1, 1, false, 'W_flow3', 1, "Client", "jsjdhjsjf", template_1]
]

workflows.each do |user_id, comp_id, templateid, completion, identifier, workflowid, workflowtype, remarks, template|
  Workflow.create(user_id: user_id, company_id: comp_id, template_id: templateid, completed: completion, identifier: identifier, workflowable_id: workflowid, workflowable_type: workflowtype, remarks: remarks, template: template)
end

# Create document template
document_template_1 = DocumentTemplate.create(title: 'Doc template 1', description: 'Describe the template of the first document', file_url: 'http://www.doc_sksij.com', template_id: 2, user_id: 1, template: template_1)

documents = [
  ['June Balance Sheet', 'Balance sheet in the month of June', 1, 'wjjkskkdkl', 3, 1, 'doc_june', 1, Workflow.find(1), document_template_1],
  ['July Balance sheet', 'Balance sheet in the month of July', 1, 'hasilwoqp', 3, 1, 'doc_july', 5, Workflow.find(2), document_template_1],
  ['Aug Balance sheet', 'Balance sheet in the month of Aug', 1, 'bewormknjvjp', 3, 1,'doc_aug', 5, Workflow.find(3), document_template_1]
]

documents.each do |file_name, remarks, comp_id, f_url, workflowid, doc_templateid, identifier, user_id, workflow, doc_template|
  Document.create(filename: file_name, remarks: remarks, company_id: comp_id, file_url:f_url, workflow_id: workflowid, document_template_id: doc_templateid, identifier:identifier, user_id: user_id, workflow: workflow, document_template: doc_template )
end

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

=begin

#Creating sections
#section_1 = Section.create(unique_name: 'Section 1', display_name: 'Finance', position: 1, template: template_1) #Id section 6
#section_2 = Section.create(unique_name: 'Section 2', display_name: 'Paper Work', position:2, template: template_1) #Id section 7
#section_3 = Section.create(unique_name: 'Section 3', display_name: 'Project Work', position: 3, template: template_1) #Id section 8


#Creating tasks
task_1 = Task.create(instructions: 'Calculate the amount of expenditure', position: 1, days_to_complete: 6, set_reminder: false, role_id: 1, task_type: 1, section: sections)
#task id 3
task_2 = Task.create(instructions: 'Calculate the payroll of employees', position: 2, section_id: 6, image_url: '', days_to_complete: 4, set_reminder: false, role_id:1, task_type:1, link_url: '', section: sections)
#task id 4
task_3 = Task.create(instructions: 'File all the papers since 1989', position: 3, section_id: 7, image_url: '', days_to_complete: 1, set_reminder: true, role_id: 2, task_type: 2, link_url: '', section: sections)
#task id 5
task_4 = Task.create(instructions: 'Shredding the papers', position: 4, section_id: 7, image_url: '', days_to_complete: 1, set_reminder: false, role_id: 2, task_type: 2, link_url: '', section: sections)
#task id 6
task_5 = Task.create(instructions: 'Do powerpoint slides for presentation', position: 4, section_id: 8, image_url: '', days_to_complete: 12, set_reminder: false, role_id: 3, task_type: 3, link_url: '', section: sections)
#task id 7
task_6 = Task.create(instructions: 'Communicate with project group friend for some correction', position: 5, section_id: 8, image_url: ' ', days_to_complete: 1, set_reminder: false, role_id: 3, task_type: 3, link_url: '', section: sections)
#task id 8
task_7 = Task.create(instructions: 'Check the balance sheet of the accountants', position: 6, section_id: 6, days_to_complete: 7, set_reminder: false, role_id: 1, task_type: 0, section: sections)
#task id 9
task_8 = Task.create(instructions: 'Get approval signature from the finance manager', position: 7, section_id: 6, days_to_complete: 1, set_reminder: true, role_id: 1, task_type: 2, section: sections)
#task id 10
task_9 = Task.create(instructions: 'Upload accounting data into company"s excel sheet', position: 8, section_id: 6, days_to_complete: 5, set_reminder: false, role_id: 1, task_type: 6, section: sections)
#task id 11
task_10 = Task.create(instructions: 'Get the supervisor of the finance department to sign important documents', position: 9, section_id: 7, days_to_complete: 2, set_reminder: false, role_id: 1, task_type: 2, section: sections)
#task id 12
task_11 = Task.create(instructions: 'Enter the data from the papers onto the excel sheet', position: 10, section_id: 7, days_to_complete: 3, set_reminder: true, role_id: 2, task_type: 6, section: sections)
#task id 13
task_12 = Task.create(instructions: 'Allocate project work to team members', position: 11, section_id: 8, days_to_complete: 1, set_reminder: false, role_id: 3, task_type: 0, section: sections)
#task id 14
task_13 = Task.create(instructions: 'Upload the main HTML document needed for the project', position: 12, section_id: 8, days_to_complete: 6, set_reminder: true, role_id: 3, task_type: 1, section: sections[2])
#task id 15
task_14 = Task.create(instructions: 'Upload profile pictures of the team members', position: 13, section_id: 8, days_to_complete: 10, set_reminder: false, role_id: 3, task_type: 5, section: sections)
#task id 16
task_15 = Task.create(instructions: 'Fold paper planes with the excess paper', position: 14, section_id: 7, days_to_complete: 4, set_reminder: false, role_id: 2, task_type: 0, section: sections)
#task id 17



#Creating workflow
work_flow1 = Workflow.create(user_id: 1, company_id: 1, template_id: 2, completed: false, identifier: 'W_flow1', workflowable_id: 1, workflowable_type: "Client", remarks: "EFGHIJ", template: template_1) #workflow id 3
work_flow2 = Workflow.create(user_id: 2, company_id: 1, template_id: 2, completed: false, identifier:'W_flow2', workflowable_id: 1, workflowable_type: 'Client', remarks: 'sdjdf', template: template_1) #workflow id 16
work_flow3 = Workflow.create(user_id: 3, company_id: 1, template_id: 2, completed: false, identifier:'W_flow3', workflowable_id: 1, workflowable_type: 'Client', remarks: 'jsjdhjsjf', template: template_1) #workflow id 15



#creating document
doc_1 = Document.create(filename: 'June Balance sheet', remarks: 'Balance sheet in the month of June', company_id: 1, file_url: 'wjjkskkdkl', workflow_id: 3, document_template_id: 1, identifier: 'doc_june', user_id: 1, workflow: work_flow1, document_template: document_template_1)
#document id 2
doc_2 = Document.create(filename: 'July Balance sheet', remarks: 'Balance sheet in the month of July', company_id: 1, file_url: 'hasilwoqp', workflow_id: 3, document_template_id: 1, identifier: 'doc_july', user_id: 5, workflow: work_flow1, document_template: document_template_1 )
#document id 3
doc_3 = Document.create(filename: 'Aug Balance sheet', remarks: 'Balance sheet in the month of Aug', company_id: 1, file_url: 'bewormknjvjp', workflow_id: 3, document_template_id: 1, identifier: 'doc_aug', user_id: 5, workflow: work_flow1, document_template: document_template_1 )
#document id 4


#create client
client_1 = Client.create(name: "Harry Potter", identifier: 'HP', user_id: 1, company_id: 1)
client_2 = Client.create(name: "Jonathan", identifier: 'JL92', user_id: 6, company_id: 1)
#client no relations?



#creating a reminder
rem_1 = Reminder.create(repeat: true, freq_value: 1,freq_unit: 2, user_id: 5, company_id: 1, title: 'Reminder for task 1', content: 'please remember to do task 1', task_id: 3, email: true, sms: false, slack: true, task: task_1, workflow_action: wfa_1)
rem_2 = Reminder.create(next_reminder: 20180629, repeat: false, freq_value: 1, freq_unit: 1, user_id: 5, company_id: 1, title: 'Reminder for task 2', content: 'Please do task 2 by the next reminder', task_id: 4, email: false, sms: true, slack: false, task: task_2, workflow_action: wfa_1)
=end

