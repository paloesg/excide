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

#creating template
test_template = Template.create(title: 'Template 1', company: gobbler)


#Creating sections
section_1 = Section.create(unique_name: 'Section 1', display_name: 'Finance', position: 1, template: test_template) #Id section 6
section_2 = Section.create(unique_name: 'Section 2', display_name: 'Paper Work', position:2, template: test_template) #Id section 7
section_3 = Section.create(unique_name: 'Section 3', display_name: 'Project Work', position: 3, template: test_template) #Id section 8

#Creating tasks
task_1 = Task.create(instructions: 'Calculate the amount of expenditure', position: 1, days_to_complete: 6, set_reminder: false, role_id: 1, task_type: 1, section: section_1)
#task id 3
task_2 = Task.create(instructions: 'Calculate the payroll of employees', position: 2, section_id: 6, image_url: '', days_to_complete: 4, set_reminder: false, role_id:1, task_type:1, link_url: '', section: section_1)
#task id 4
task_3 = Task.create(instructions: 'File all the papers since 1989', position: 3, section_id: 7, image_url: '', days_to_complete: 1, set_reminder: true, role_id: 2, task_type: 2, link_url: '', section: section_2)
#task id 5
task_4 = Task.create(instructions: 'Shredding the papers', position: 4, section_id: 7, image_url: '', days_to_complete: 1, set_reminder: false, role_id: 2, task_type: 2, link_url: '', section: section_2)
#task id 6
task_5 = Task.create(instructions: 'Do powerpoint slides for presentation', position: 4, section_id: 8, image_url: '', days_to_complete: 12, set_reminder: false, role_id: 3, task_type: 3, link_url: '', section: section_3)
#task id 7
task_6 = Task.create(instructions: 'Communicate with project group friend for some correction', position: 5, section_id: 8, image_url: ' ', days_to_complete: 1, set_reminder: false, role_id: 3, task_type: 3, link_url: '', section: section_3)
#task id 8
task_7 = Task.create(instructions: 'Check the balance sheet of the accountants', position: 6, section_id: 6, days_to_complete: 7, set_reminder: false, role_id: 1, task_type: 0, section: section_1)
#task id 9
task_8 = Task.create(instructions: 'Get approval signature from the finance manager', position: 7, section_id: 6, days_to_complete: 1, set_reminder: true, role_id: 1, task_type: 2, section: section_1)
#task id 10
task_9 = Task.create(instructions: 'Upload accounting data into company"s excel sheet', position: 8, section_id: 6, days_to_complete: 5, set_reminder: false, role_id: 1, task_type: 6, section: section_1)
#task id 11
task_10 = Task.create(instructions: 'Get the supervisor of the finance department to sign important documents', position: 9, section_id: 7, days_to_complete: 2, set_reminder: false, role_id: 1, task_type: 2, section: section_2)
#task id 12
task_11 = Task.create(instructions: 'Enter the data from the papers onto the excel sheet', position: 10, section_id: 7, days_to_complete: 3, set_reminder: true, role_id: 2, task_type: 6, section: section_2)
#task id 13
task_12 = Task.create(instructions: 'Allocate project work to team members', position: 11, section_id: 8, days_to_complete: 1, set_reminder: false, role_id: 3, task_type: 0, section: section_3)
#task id 14
task_13 = Task.create(instructions: 'Upload the main HTML document needed for the project', position: 12, section_id: 8, days_to_complete: 6, set_reminder: true, role_id: 3, task_type: 1, section: section_3)
#task id 15
task_14 = Task.create(instructions: 'Upload profile pictures of the team members', position: 13, section_id: 8, days_to_complete: 10, set_reminder: false, role_id: 3, task_type: 5, section: section_3)
#task id 16
task_15 = Task.create(instructions: 'Fold paper planes with the excess paper', position: 14, section_id: 7, days_to_complete: 4, set_reminder: false, role_id: 2, task_type: 0, section: section_2)
#task id 17

#Creating workflow
work_flow1 = Workflow.create(user_id: 1, company_id: 1, template_id: 2, completed: false, identifier: 'W_flow1', workflowable_id: 1, workflowable_type: "Client", remarks: "EFGHIJ", template: test_template) #workflow id 3
work_flow2 = Workflow.create(user_id: 2, company_id: 1, template_id: 2, completed: false, identifier:'W_flow2', workflowable_id: 1, workflowable_type: 'Client', remarks: 'sdjdf', template: test_template) #workflow id 16
work_flow3 = Workflow.create(user_id: 3, company_id: 1, template_id: 2, completed: false, identifier:'W_flow3', workflowable_id: 1, workflowable_type: 'Client', remarks: 'jsjdhjsjf', template: test_template) #workflow id 15

#create document-template
doc_tem_1 = DocumentTemplate.create(title: 'Doc template 1', description: 'Describe the template of the first document', file_url: 'http://www.doc_sksij.com', template_id: 2, user_id: 1, template: test_template)

#creating document
doc_1 = Document.create(filename: 'June Balance sheet', remarks: 'Balance sheet in the month of June', company_id: 1, file_url: 'wjjkskkdkl', workflow_id: 3, document_template_id: 1, identifier: 'doc_june', user_id: 1, workflow: work_flow1, document_template: doc_tem_1)
#document id 2
doc_2 = Document.create(filename: 'July Balance sheet', remarks: 'Balance sheet in the month of July', company_id: 1, file_url: 'hasilwoqp', workflow_id: 3, document_template_id: 1, identifier: 'doc_july', user_id: 5, workflow: work_flow1, document_template: doc_tem_1 )
#document id 3
doc_3 = Document.create(filename: 'Aug Balance sheet', remarks: 'Balance sheet in the month of Aug', company_id: 1, file_url: 'bewormknjvjp', workflow_id: 3, document_template_id: 1, identifier: 'doc_aug', user_id: 5, workflow: work_flow1, document_template: doc_tem_1 )
#document id 4

#create client
client_1 = Client.create(name: "Harry Potter", identifier: 'HP', user_id: 1, company_id: 1)
client_2 = Client.create(name: "Jonathan", identifier: 'JL92', user_id: 6, company_id: 1)
#client no relations?

#create workflowaction
wfa_1 = WorkflowAction.create(task_id: 3, completed: false, company_id: 1, workflow_id: 1, workflow: work_flow1)
#workflowaction_id 62

#creating a reminder
rem_1 = Reminder.create(repeat: true, freq_value: 1,freq_unit: 2, user_id: 5, company_id: 1, title: 'Reminder for task 1', content: 'please remember to do task 1', task_id: 3, email: true, sms: false, slack: true, task: task_1, workflow_action: wfa_1)
rem_2 = Reminder.create(next_reminder: 20180629, repeat: false, freq_value: 1, freq_unit: 1, user_id: 5, company_id: 1, title: 'Reminder for task 2', content: 'Please do task 2 by the next reminder', task_id: 4, email: false, sms: true, slack: false, task: task_2, workflow_action: wfa_1)


