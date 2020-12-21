class ChangeCompanyIdToUuid < ActiveRecord::Migration[6.0]
  def up
    PublicActivity.enabled = false

    # remove the old foreign_key
    remove_foreign_key :batches, :companies
    remove_foreign_key :clients, :companies
    remove_foreign_key :contacts, :companies
    remove_foreign_key :documents, :companies
    remove_foreign_key :events, :companies
    remove_foreign_key :folders, :companies
    remove_foreign_key :invoices, :companies
    remove_foreign_key :outlets, :companies
    remove_foreign_key :recurring_workflows, :companies
    remove_foreign_key :reminders, :companies
    remove_foreign_key :surveys, :companies
    remove_foreign_key :survey_templates, :companies
    remove_foreign_key :templates, :companies
    remove_foreign_key :users, :companies
    remove_foreign_key :workflows, :companies
    remove_foreign_key :workflow_actions, :companies
    remove_foreign_key :xero_tracking_categories, :companies
    remove_foreign_key :xero_contacts, :companies
    remove_foreign_key :xero_line_items, :companies
    add_column :companies, :uuid, :uuid, default: "gen_random_uuid()", null: false
    # Add temporary uuid column for associated model
    add_column :batches, :company_uuid, :uuid
    add_column :clients, :company_uuid, :uuid
    add_column :contacts, :company_uuid, :uuid
    add_column :documents, :company_uuid, :uuid
    add_column :events, :company_uuid, :uuid
    add_column :folders, :company_uuid, :uuid
    add_column :invoices, :company_uuid, :uuid
    add_column :outlets, :company_uuid, :uuid
    add_column :recurring_workflows, :company_uuid, :uuid
    add_column :reminders, :company_uuid, :uuid
    add_column :surveys, :company_uuid, :uuid
    add_column :survey_templates, :company_uuid, :uuid
    add_column :templates, :company_uuid, :uuid
    add_column :users, :company_uuid, :uuid
    add_column :workflows, :company_uuid, :uuid
    add_column :workflow_actions, :company_uuid, :uuid
    add_column :xero_tracking_categories, :company_uuid, :uuid
    add_column :xero_contacts, :company_uuid, :uuid
    add_column :xero_line_items, :company_uuid, :uuid
    add_column :addresses, :company_uuid, :uuid
    add_column :roles, :company_uuid, :uuid
    Company.find_each do |c|
      say "Creating a company #{c.name}"
      Address.where(addressable_id: c.id).find_each do |add|
        say "Created an address #{add.id}"
        add.company_uuid = c.uuid
        add.save!
      end
      Role.where(resource_id: c.id).find_each do |role|
        say "Created a role #{role.id}"
        role.company_uuid = c.uuid
        role.save!
      end
      Batch.where(company_id: c.id).find_in_batches(batch_size: 100) do |batches|
        batches.each do |batch|
          say "Created a batch #{batch.id}"
          batch.company_uuid = c.uuid
          batch.save!
        end
      end
      Client.where(company_id: c.id).find_in_batches(batch_size: 100) do |clients|
        clients.each do |client|
          say "Created a client #{client.id}"
          client.company_uuid = c.uuid
          client.save!
        end
      end
      Contact.where(company_id: c.id).find_each do |contact|
        say "Created a contact #{contact.id}"
        contact.company_uuid = c.uuid
        contact.save!
      end
      Document.where(company_id: c.id).find_in_batches(batch_size: 100) do |documents|
        documents.each do |document|
          say "Created a doc #{document.id}"
          document.company_uuid = c.uuid
          document.save!
        end
      end
      Event.where(company_id: c.id).find_in_batches(batch_size: 100) do |events|
        events.each do |event|
          say "Created an event #{event.id}"
          event.company_uuid = c.uuid
          event.save(validate: false)
        end
      end
      Folder.where(company_id: c.id).find_each do |folder|
        say "Created a folder #{folder.id}"
        folder.company_uuid = c.uuid
        folder.save!
      end
      Invoice.where(company_id: c.id).find_in_batches(batch_size: 100) do |invs|
        invs.each do |inv|
          say "Created a invoice #{inv.id}"
          inv.company_uuid = c.uuid
          inv.save(validate: false)
        end
      end
      Outlet.where(company_id: c.id).find_each do |outlet|
        say "Created a outlet #{outlet.id}"
        outlet.company_uuid = c.uuid
        outlet.save!
      end
      RecurringWorkflow.where(company_id: c.id).find_each do |rec|
        say "Created a recurring wf #{rec.id}"
        rec.company_uuid = c.uuid
        rec.save!
      end
      Reminder.where(company_id: c.id).find_each do |reminder|
        say "Created a reminder #{reminder.id}"
        reminder.company_uuid = c.uuid
        reminder.save!
      end
      Survey.where(company_id: c.id).find_each do |survey|
        say "Created a survey #{survey.id}"
        survey.company_uuid = c.uuid
        survey.save!
      end
      SurveyTemplate.where(company_id: c.id).find_each do |sur_tem|
        say "Created a survey tem #{sur_tem.id}"
        sur_tem.company_uuid = c.uuid
        sur_tem.save!
      end
      Template.where(company_id: c.id).find_each do |tem|
        say "Created a tem #{tem.id}"
        tem.company_uuid = c.uuid
        tem.save!
      end
      User.where(company_id: c.id).find_each do |user|
        say "Created a user #{user.id}"
        user.company_uuid = c.uuid
        user.save!
      end
      Workflow.where(company_id: c.id).find_in_batches(batch_size: 100) do |wfs|
        wfs.each do |wf|
          say "Created a wf #{wf.id}"
          wf.company_uuid = c.uuid
          wf.save!
        end
      end
      WorkflowAction.where(company_id: c.id).find_in_batches(batch_size: 100) do |wfas|
        wfas.each do |wfa|
          say "Created a wfa #{wfa.id}"
          wfa.company_uuid = c.uuid
          wfa.save!
        end
      end
      XeroTrackingCategory.where(company_id: c.id).find_in_batches(batch_size: 100) do |xero_tracking_categories|
        xero_tracking_categories.each do |xero_tracking_category|
          say "Created a xerotc #{xero_tracking_category.id}"
          xero_tracking_category.company_uuid = c.uuid
          xero_tracking_category.save!
        end
      end
      XeroContact.where(company_id: c.id).find_in_batches(batch_size: 100) do |xero_contacts|
        xero_contacts.each do |xero_contact|
          say "Created a xerocontacts #{xero_contact.id}"
          xero_contact.company_uuid = c.uuid
          xero_contact.save!
        end
      end
      XeroLineItem.where(company_id: c.id).find_in_batches(batch_size: 100) do |xero_line_items|
        xero_line_items.each do |xero_line_item|
          say "Created a xeroline #{xero_line_item.id}"
          xero_line_item.company_uuid = c.uuid
          xero_line_item.save!
        end
      end
    end
    # Remove company_id references from related table
    remove_reference :batches, :company
    remove_reference :clients, :company
    remove_reference :contacts, :company
    remove_reference :documents, :company
    remove_reference :events, :company
    remove_reference :folders, :company
    remove_reference :invoices, :company
    remove_reference :outlets, :company
    remove_reference :recurring_workflows, :company
    remove_reference :reminders, :company
    remove_reference :surveys, :company
    remove_reference :survey_templates, :company
    remove_reference :templates, :company
    remove_reference :users, :company
    remove_reference :workflows, :company
    remove_reference :workflow_actions, :company
    remove_reference :xero_tracking_categories, :company
    remove_reference :xero_contacts, :company
    remove_reference :xero_line_items, :company
    # Remove polymorphic association ID
    remove_column :addresses, :addressable_id
    remove_column :roles, :resource_id


    say "Before change table"
    change_table :companies do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE companies ADD PRIMARY KEY (id);"
    say "Rename column"

    rename_column :batches, :company_uuid, :company_id
    rename_column :clients, :company_uuid, :company_id
    rename_column :contacts, :company_uuid, :company_id
    rename_column :documents, :company_uuid, :company_id
    rename_column :events, :company_uuid, :company_id
    rename_column :folders, :company_uuid, :company_id
    rename_column :invoices, :company_uuid, :company_id
    rename_column :outlets, :company_uuid, :company_id
    rename_column :recurring_workflows, :company_uuid, :company_id
    rename_column :reminders, :company_uuid, :company_id
    rename_column :surveys, :company_uuid, :company_id
    rename_column :survey_templates, :company_uuid, :company_id
    rename_column :templates, :company_uuid, :company_id
    rename_column :users, :company_uuid, :company_id
    rename_column :workflows, :company_uuid, :company_id
    rename_column :workflow_actions, :company_uuid, :company_id
    rename_column :xero_tracking_categories, :company_uuid, :company_id
    rename_column :xero_contacts, :company_uuid, :company_id
    rename_column :xero_line_items, :company_uuid, :company_id
    # Change uuid back to polymorphic association id
    rename_column :addresses, :company_uuid, :addressable_id
    rename_column :roles, :company_uuid, :resource_id

    # remove the old foreign_key
    add_foreign_key :batches, :companies
    add_foreign_key :clients, :companies
    add_foreign_key :contacts, :companies
    add_foreign_key :documents, :companies
    add_foreign_key :events, :companies
    add_foreign_key :folders, :companies
    add_foreign_key :invoices, :companies
    add_foreign_key :outlets, :companies
    add_foreign_key :recurring_workflows, :companies
    add_foreign_key :reminders, :companies
    add_foreign_key :surveys, :companies
    add_foreign_key :survey_templates, :companies
    add_foreign_key :templates, :companies
    add_foreign_key :users, :companies
    add_foreign_key :workflows, :companies
    add_foreign_key :workflow_actions, :companies
    add_foreign_key :xero_tracking_categories, :companies
    add_foreign_key :xero_contacts, :companies
    add_foreign_key :xero_line_items, :companies

    PublicActivity.enabled = true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
