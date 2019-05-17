# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_16_122235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activation_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "colour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "activations", id: :serial, force: :cascade do |t|
    t.integer "activation_type_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text "remarks"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.integer "event_owner_id"
    t.integer "client_id"
    t.index ["client_id"], name: "index_activations_on_client_id"
    t.index ["company_id"], name: "index_activations_on_company_id"
    t.index ["event_owner_id"], name: "index_activations_on_event_owner_id"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "trackable_id"
    t.string "trackable_type"
    t.integer "owner_id"
    t.string "owner_type"
    t.string "key"
    t.text "parameters"
    t.integer "recipient_id"
    t.string "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "line_1"
    t.string "line_2"
    t.string "postal_code"
    t.integer "addressable_id"
    t.string "addressable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "allocations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "activation_id"
    t.date "allocation_date"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "allocation_type"
    t.boolean "last_minute", default: false
    t.integer "rate_cents"
    t.index ["activation_id"], name: "index_allocations_on_activation_id"
    t.index ["user_id"], name: "index_allocations_on_user_id"
  end

  create_table "availabilities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.date "available_date"
    t.time "start_time"
    t.time "end_time"
    t.boolean "assigned", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_availabilities_on_user_id"
  end

  create_table "choices", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "choices_questions", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "choice_id", null: false
    t.index ["question_id", "choice_id"], name: "index_choices_questions_on_question_id_and_choice_id"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "xero_contact_id"
    t.string "xero_email"
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
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
    t.string "xero_email"
    t.string "uen"
    t.text "contact_details"
    t.date "agm_date"
    t.date "ar_date"
    t.date "eci_date"
    t.date "form_cs_date"
    t.integer "gst_quarter"
    t.date "project_start_date"
    t.bigint "consultant_id"
    t.bigint "associate_id"
    t.bigint "shared_service_id"
    t.string "designated_working_time"
    t.index ["associate_id"], name: "index_companies_on_associate_id"
    t.index ["consultant_id"], name: "index_companies_on_consultant_id"
    t.index ["shared_service_id"], name: "index_companies_on_shared_service_id"
  end

  create_table "document_templates", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "file_url"
    t.integer "template_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_document_templates_on_template_id"
    t.index ["user_id"], name: "index_document_templates_on_user_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "filename"
    t.text "remarks"
    t.integer "company_id"
    t.date "date_signed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_url"
    t.integer "workflow_id"
    t.integer "document_template_id"
    t.integer "user_id"
    t.index ["company_id"], name: "index_documents_on_company_id"
    t.index ["document_template_id"], name: "index_documents_on_document_template_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
    t.index ["workflow_id"], name: "index_documents_on_workflow_id"
  end

  create_table "enquiries", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "email"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source"
    t.boolean "responded", default: false
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
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

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "invoice_identifier"
    t.date "invoice_date"
    t.date "due_date"
    t.json "line_items", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workflow_id"
    t.integer "line_amount_type"
    t.integer "invoice_type"
    t.string "xero_invoice_id"
    t.string "invoice_reference"
    t.string "xero_contact_id"
    t.string "xero_contact_name"
    t.string "currency"
    t.boolean "approved"
    t.decimal "total"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
    t.index ["workflow_id"], name: "index_invoices_on_workflow_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
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

  create_table "questions", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "question_type"
    t.integer "position"
    t.integer "survey_section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_section_id"], name: "index_questions_on_survey_section_id"
  end

  create_table "recurring_workflows", force: :cascade do |t|
    t.integer "freq_value"
    t.integer "freq_unit"
    t.bigint "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "next_workflow_date"
    t.bigint "company_id"
    t.bigint "user_id"
    t.index ["company_id"], name: "index_recurring_workflows_on_company_id"
    t.index ["template_id"], name: "index_recurring_workflows_on_template_id"
    t.index ["user_id"], name: "index_recurring_workflows_on_user_id"
  end

  create_table "reminders", id: :serial, force: :cascade do |t|
    t.datetime "next_reminder"
    t.boolean "repeat"
    t.integer "freq_value"
    t.integer "freq_unit"
    t.datetime "past_reminders", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "company_id"
    t.string "title"
    t.text "content"
    t.integer "task_id"
    t.integer "workflow_action_id"
    t.boolean "email"
    t.boolean "sms"
    t.boolean "slack"
    t.index ["company_id"], name: "index_reminders_on_company_id"
    t.index ["task_id"], name: "index_reminders_on_task_id"
    t.index ["user_id"], name: "index_reminders_on_user_id"
    t.index ["workflow_action_id"], name: "index_reminders_on_workflow_action_id"
  end

  create_table "responses", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "question_id"
    t.integer "choice_id"
    t.integer "segment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_id"], name: "index_responses_on_choice_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["segment_id"], name: "index_responses_on_segment_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.string "unique_name"
    t.string "display_name"
    t.integer "position"
    t.integer "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_sections_on_template_id"
  end

  create_table "segments", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.integer "survey_section_id"
    t.integer "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_segments_on_survey_id"
    t.index ["survey_section_id"], name: "index_segments_on_survey_section_id"
  end

  create_table "survey_sections", id: :serial, force: :cascade do |t|
    t.string "unique_name"
    t.string "display_name"
    t.integer "position"
    t.integer "survey_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_template_id"], name: "index_survey_sections_on_survey_template_id"
  end

  create_table "survey_templates", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "survey_type"
  end

  create_table "surveys", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "remarks"
    t.integer "user_id"
    t.integer "company_id"
    t.integer "survey_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_surveys_on_company_id"
    t.index ["survey_template_id"], name: "index_surveys_on_survey_template_id"
    t.index ["user_id"], name: "index_surveys_on_user_id"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.string "instructions"
    t.integer "position"
    t.integer "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.integer "days_to_complete"
    t.boolean "set_reminder"
    t.integer "role_id"
    t.integer "task_type"
    t.integer "document_template_id"
    t.string "link_url"
    t.index ["document_template_id"], name: "index_tasks_on_document_template_id"
    t.index ["role_id"], name: "index_tasks_on_role_id"
    t.index ["section_id"], name: "index_tasks_on_section_id"
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "business_model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "company_id"
    t.json "data_names", default: []
    t.integer "workflow_type", default: 0
    t.index ["company_id"], name: "index_templates_on_company_id"
    t.index ["slug"], name: "index_templates_on_slug", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
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
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "aasm_state"
    t.integer "company_id"
    t.integer "max_hours_per_week"
    t.string "nric"
    t.string "bank_name"
    t.string "bank_account_number"
    t.integer "bank_account_type"
    t.date "date_of_birth"
    t.text "remarks"
    t.string "bank_account_name"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "workflow_actions", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deadline"
    t.integer "company_id"
    t.integer "approved_by"
    t.integer "workflow_id"
    t.integer "assigned_user_id"
    t.integer "completed_user_id"
    t.text "remarks"
    t.index ["assigned_user_id"], name: "index_workflow_actions_on_assigned_user_id"
    t.index ["company_id"], name: "index_workflow_actions_on_company_id"
    t.index ["completed_user_id"], name: "index_workflow_actions_on_completed_user_id"
    t.index ["task_id"], name: "index_workflow_actions_on_task_id"
    t.index ["workflow_id"], name: "index_workflow_actions_on_workflow_id"
  end

  create_table "workflows", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "company_id"
    t.integer "template_id"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deadline"
    t.string "identifier"
    t.integer "workflowable_id"
    t.string "workflowable_type"
    t.text "remarks"
    t.json "data", default: []
    t.json "archive", default: []
    t.bigint "recurring_workflow_id"
    t.index ["company_id"], name: "index_workflows_on_company_id"
    t.index ["recurring_workflow_id"], name: "index_workflows_on_recurring_workflow_id"
    t.index ["template_id"], name: "index_workflows_on_template_id"
    t.index ["user_id"], name: "index_workflows_on_user_id"
    t.index ["workflowable_type", "workflowable_id"], name: "index_workflows_on_workflowable_type_and_workflowable_id"
  end

  add_foreign_key "activations", "clients"
  add_foreign_key "activations", "companies"
  add_foreign_key "activations", "users", column: "event_owner_id"
  add_foreign_key "allocations", "activations"
  add_foreign_key "allocations", "users"
  add_foreign_key "availabilities", "users"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "companies", "users", column: "associate_id"
  add_foreign_key "companies", "users", column: "consultant_id"
  add_foreign_key "companies", "users", column: "shared_service_id"
  add_foreign_key "document_templates", "templates"
  add_foreign_key "document_templates", "users"
  add_foreign_key "documents", "companies"
  add_foreign_key "documents", "document_templates"
  add_foreign_key "documents", "users"
  add_foreign_key "documents", "workflows"
  add_foreign_key "invoices", "users"
  add_foreign_key "invoices", "workflows"
  add_foreign_key "profiles", "users"
  add_foreign_key "questions", "sections", column: "survey_section_id"
  add_foreign_key "recurring_workflows", "companies"
  add_foreign_key "recurring_workflows", "templates"
  add_foreign_key "recurring_workflows", "users"
  add_foreign_key "reminders", "companies"
  add_foreign_key "reminders", "tasks"
  add_foreign_key "reminders", "users"
  add_foreign_key "reminders", "workflow_actions"
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
  add_foreign_key "tasks", "document_templates"
  add_foreign_key "tasks", "roles"
  add_foreign_key "tasks", "sections"
  add_foreign_key "templates", "companies"
  add_foreign_key "users", "companies"
  add_foreign_key "workflow_actions", "companies"
  add_foreign_key "workflow_actions", "tasks"
  add_foreign_key "workflow_actions", "users", column: "assigned_user_id"
  add_foreign_key "workflow_actions", "users", column: "completed_user_id"
  add_foreign_key "workflow_actions", "workflows"
  add_foreign_key "workflows", "companies"
  add_foreign_key "workflows", "recurring_workflows"
  add_foreign_key "workflows", "templates"
  add_foreign_key "workflows", "users"
end
