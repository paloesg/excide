class InitSchema < ActiveRecord::Migration
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "activities" do |t|
      t.string "trackable_type"
      t.bigint "trackable_id"
      t.string "owner_type"
      t.bigint "owner_id"
      t.string "key"
      t.text "parameters"
      t.string "recipient_type"
      t.bigint "recipient_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
      t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
      t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
      t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
      t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
      t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
    end
    create_table "addresses" do |t|
      t.string "line_1"
      t.string "line_2"
      t.string "postal_code"
      t.string "addressable_type"
      t.bigint "addressable_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
    end
    create_table "choices" do |t|
      t.text "content"
      t.integer "position"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "choices_questions", id: false do |t|
      t.bigint "question_id", null: false
      t.bigint "choice_id", null: false
      t.index ["question_id", "choice_id"], name: "index_choices_questions_on_question_id_and_choice_id"
    end
    create_table "clients" do |t|
      t.string "name"
      t.string "identifier"
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_clients_on_user_id"
    end
    create_table "companies" do |t|
      t.string "name"
      t.string "industry"
      t.integer "company_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "image_url"
      t.text "description"
      t.string "title"
      t.string "linkedin_url"
      t.string "aasm_state"
      t.string "ssic_code"
      t.date "financial_year_end"
      t.string "slug"
    end
    create_table "company_actions" do |t|
      t.bigint "task_id"
      t.boolean "completed"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deadline"
      t.bigint "company_id"
      t.integer "approved_by"
      t.bigint "workflow_id"
      t.index ["company_id"], name: "index_company_actions_on_company_id"
      t.index ["task_id"], name: "index_company_actions_on_task_id"
      t.index ["workflow_id"], name: "index_company_actions_on_workflow_id"
    end
    create_table "document_templates" do |t|
      t.string "title"
      t.text "description"
      t.string "file_url"
      t.bigint "template_id"
      t.bigint "task_id"
      t.bigint "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["task_id"], name: "index_document_templates_on_task_id"
      t.index ["template_id"], name: "index_document_templates_on_template_id"
      t.index ["user_id"], name: "index_document_templates_on_user_id"
    end
    create_table "documents" do |t|
      t.string "filename"
      t.text "remarks"
      t.bigint "company_id"
      t.date "date_signed"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "file_url"
      t.bigint "workflow_id"
      t.bigint "document_template_id"
      t.string "identifier"
      t.index ["company_id"], name: "index_documents_on_company_id"
      t.index ["document_template_id"], name: "index_documents_on_document_template_id"
      t.index ["workflow_id"], name: "index_documents_on_workflow_id"
    end
    create_table "enquiries" do |t|
      t.string "name"
      t.string "contact"
      t.string "email"
      t.text "comments"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "source"
      t.boolean "responded", default: false
    end
    create_table "experiences" do |t|
      t.bigint "profile_id"
      t.string "title"
      t.string "company"
      t.date "start_date"
      t.date "end_date"
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["profile_id"], name: "index_experiences_on_profile_id"
    end
    create_table "friendly_id_slugs" do |t|
      t.string "slug", null: false
      t.integer "sluggable_id", null: false
      t.string "sluggable_type", limit: 50
      t.string "scope"
      t.datetime "created_at"
      t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
      t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
      t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
      t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    end
    create_table "profiles" do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "user_id"
      t.string "headline"
      t.text "summary"
      t.string "industry"
      t.string "specialties"
      t.string "image_url"
      t.string "linkedin_url"
      t.string "location"
      t.string "country_code"
      t.string "display_name"
      t.index ["user_id"], name: "index_profiles_on_user_id"
    end
    create_table "project_categories" do |t|
      t.string "name"
      t.integer "status"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "parent_id"
    end
    create_table "projects" do |t|
      t.string "title"
      t.integer "project_category_id"
      t.text "description"
      t.datetime "start_date"
      t.datetime "end_date"
      t.integer "budget"
      t.integer "budget_type"
      t.text "remarks"
      t.integer "status"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "company_id"
      t.text "criteria"
      t.integer "grant"
      t.index ["company_id"], name: "index_projects_on_company_id"
    end
    create_table "proposals" do |t|
      t.bigint "profile_id"
      t.text "qualifications"
      t.integer "amount"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "file_url"
      t.bigint "project_id"
      t.integer "status"
      t.index ["profile_id"], name: "index_proposals_on_profile_id"
      t.index ["project_id"], name: "index_proposals_on_project_id"
    end
    create_table "qualifications" do |t|
      t.bigint "profile_id"
      t.string "institution"
      t.string "title"
      t.integer "year_obtained"
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["profile_id"], name: "index_qualifications_on_profile_id"
    end
    create_table "questions" do |t|
      t.text "content"
      t.integer "question_type"
      t.integer "position"
      t.bigint "survey_section_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["survey_section_id"], name: "index_questions_on_survey_section_id"
    end
    create_table "reminders" do |t|
      t.datetime "next_reminder"
      t.boolean "repeat"
      t.integer "freq_value"
      t.integer "freq_unit"
      t.datetime "past_reminders", default: [], array: true
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "user_id"
      t.bigint "company_id"
      t.string "title"
      t.text "content"
      t.bigint "task_id"
      t.bigint "company_action_id"
      t.index ["company_action_id"], name: "index_reminders_on_company_action_id"
      t.index ["company_id"], name: "index_reminders_on_company_id"
      t.index ["task_id"], name: "index_reminders_on_task_id"
      t.index ["user_id"], name: "index_reminders_on_user_id"
    end
    create_table "responses" do |t|
      t.text "content"
      t.bigint "question_id"
      t.bigint "choice_id"
      t.bigint "segment_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["choice_id"], name: "index_responses_on_choice_id"
      t.index ["question_id"], name: "index_responses_on_question_id"
      t.index ["segment_id"], name: "index_responses_on_segment_id"
    end
    create_table "roles" do |t|
      t.string "name"
      t.string "resource_type"
      t.bigint "resource_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
      t.index ["name"], name: "index_roles_on_name"
      t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
    end
    create_table "sections" do |t|
      t.string "section_name"
      t.string "display_name"
      t.integer "position"
      t.bigint "template_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["template_id"], name: "index_sections_on_template_id"
    end
    create_table "segments" do |t|
      t.string "name"
      t.integer "position"
      t.bigint "survey_section_id"
      t.bigint "survey_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["survey_id"], name: "index_segments_on_survey_id"
      t.index ["survey_section_id"], name: "index_segments_on_survey_section_id"
    end
    create_table "survey_sections" do |t|
      t.string "unique_name"
      t.string "display_name"
      t.integer "position"
      t.bigint "survey_template_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["survey_template_id"], name: "index_survey_sections_on_survey_template_id"
    end
    create_table "survey_templates" do |t|
      t.string "title"
      t.string "slug"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "survey_type"
    end
    create_table "surveys" do |t|
      t.string "title"
      t.text "remarks"
      t.bigint "user_id"
      t.bigint "company_id"
      t.bigint "survey_template_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["company_id"], name: "index_surveys_on_company_id"
      t.index ["survey_template_id"], name: "index_surveys_on_survey_template_id"
      t.index ["user_id"], name: "index_surveys_on_user_id"
    end
    create_table "tasks" do |t|
      t.string "instructions"
      t.integer "position"
      t.bigint "section_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "image_url"
      t.integer "days_to_complete"
      t.boolean "set_reminder"
      t.bigint "role_id"
      t.integer "task_type"
      t.index ["role_id"], name: "index_tasks_on_role_id"
      t.index ["section_id"], name: "index_tasks_on_section_id"
    end
    create_table "templates" do |t|
      t.string "title"
      t.integer "business_model"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "slug"
      t.bigint "company_id"
      t.index ["company_id"], name: "index_templates_on_company_id"
      t.index ["slug"], name: "index_templates_on_slug", unique: true
    end
    create_table "users" do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.string "provider"
      t.string "uid"
      t.string "first_name"
      t.string "last_name"
      t.string "contact_number"
      t.boolean "allow_contact"
      t.boolean "agree_terms"
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string "unconfirmed_email"
      t.string "aasm_state"
      t.bigint "company_id"
      t.index ["company_id"], name: "index_users_on_company_id"
      t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["provider"], name: "index_users_on_provider"
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["uid"], name: "index_users_on_uid"
    end
    create_table "users_roles", id: false do |t|
      t.bigint "user_id"
      t.bigint "role_id"
      t.index ["role_id"], name: "index_users_roles_on_role_id"
      t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
      t.index ["user_id"], name: "index_users_roles_on_user_id"
    end
    create_table "workflows" do |t|
      t.bigint "user_id"
      t.bigint "company_id"
      t.bigint "template_id"
      t.boolean "completed"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deadline"
      t.string "identifier"
      t.string "workflowable_type"
      t.bigint "workflowable_id"
      t.index ["company_id"], name: "index_workflows_on_company_id"
      t.index ["template_id"], name: "index_workflows_on_template_id"
      t.index ["user_id"], name: "index_workflows_on_user_id"
      t.index ["workflowable_type", "workflowable_id"], name: "index_workflows_on_workflowable_type_and_workflowable_id"
    end
    add_foreign_key "clients", "users"
    add_foreign_key "company_actions", "companies"
    add_foreign_key "company_actions", "tasks"
    add_foreign_key "company_actions", "workflows"
    add_foreign_key "document_templates", "tasks"
    add_foreign_key "document_templates", "templates"
    add_foreign_key "document_templates", "users"
    add_foreign_key "documents", "companies"
    add_foreign_key "documents", "document_templates"
    add_foreign_key "documents", "workflows"
    add_foreign_key "experiences", "profiles"
    add_foreign_key "profiles", "users"
    add_foreign_key "projects", "companies"
    add_foreign_key "proposals", "profiles"
    add_foreign_key "proposals", "projects"
    add_foreign_key "qualifications", "profiles"
    add_foreign_key "questions", "sections", column: "survey_section_id"
    add_foreign_key "reminders", "companies"
    add_foreign_key "reminders", "company_actions"
    add_foreign_key "reminders", "tasks"
    add_foreign_key "reminders", "users"
    add_foreign_key "responses", "choices"
    add_foreign_key "responses", "questions"
    add_foreign_key "responses", "segments"
    add_foreign_key "sections", "templates"
    add_foreign_key "segments", "sections", column: "survey_section_id"
    add_foreign_key "segments", "surveys"
    add_foreign_key "survey_sections", "survey_templates"
    add_foreign_key "surveys", "companies"
    add_foreign_key "surveys", "templates", column: "survey_template_id"
    add_foreign_key "surveys", "users"
    add_foreign_key "tasks", "roles"
    add_foreign_key "tasks", "sections"
    add_foreign_key "templates", "companies"
    add_foreign_key "users", "companies"
    add_foreign_key "workflows", "companies"
    add_foreign_key "workflows", "templates"
    add_foreign_key "workflows", "users"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
