# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_08_125818) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "action_mailbox_inbound_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.string "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id_int"
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.uuid "record_id"
    t.boolean "current_version", default: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.string "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "line_1"
    t.string "line_2"
    t.string "postal_code"
    t.string "addressable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.string "country"
    t.string "state"
    t.uuid "addressable_id"
  end

  create_table "allocations", force: :cascade do |t|
    t.bigint "user_id"
    t.date "allocation_date"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "allocation_type"
    t.boolean "last_minute", default: false
    t.integer "rate_cents"
    t.bigint "availability_id"
    t.uuid "event_id"
    t.index ["availability_id"], name: "index_allocations_on_availability_id"
    t.index ["user_id"], name: "index_allocations_on_user_id"
  end

  create_table "availabilities", force: :cascade do |t|
    t.bigint "user_id"
    t.date "available_date"
    t.time "start_time"
    t.time "end_time"
    t.boolean "assigned", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_availabilities_on_user_id"
  end

  create_table "batches", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.bigint "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "completed", default: false
    t.integer "workflow_progress"
    t.integer "task_progress"
    t.integer "status"
    t.json "failed_blob", default: {"blobs"=>[]}
    t.uuid "company_id"
    t.index ["template_id"], name: "index_batches_on_template_id"
    t.index ["user_id"], name: "index_batches_on_user_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "category_type"
    t.uuid "department_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_categories_on_department_id"
  end

  create_table "choices", force: :cascade do |t|
    t.text "content"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "choices_questions", id: false, force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "choice_id", null: false
    t.index ["question_id", "choice_id"], name: "index_choices_questions_on_question_id_and_choice_id"
  end

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "xero_contact_id"
    t.string "xero_email"
    t.uuid "company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.string "session_handle"
    t.string "access_key"
    t.string "access_secret"
    t.integer "expires_at"
    t.boolean "connect_xero", default: true
    t.string "xero_organisation_name"
    t.integer "account_type"
    t.datetime "trial_end_date"
    t.json "stripe_subscription_plan_data", default: []
    t.json "slack_access_response"
    t.string "mailbox_token"
    t.integer "before_deadline_reminder_days"
    t.json "products", default: []
    t.string "website_url"
    t.string "report_url"
    t.string "cap_table_url"
    t.json "settings", default: [{"search_feature"=>"true", "kanban_board"=>"true", "dataroom"=>"true", "our_investor_or_startup"=>"true", "cap_table"=>"true", "performance_report"=>"true", "shared_file"=>"true", "resource_portal"=>"true", "announcement"=>"true"}]
    t.bigint "storage_used", default: 0
    t.bigint "storage_limit", default: 5368709120
    t.index ["associate_id"], name: "index_companies_on_associate_id"
    t.index ["consultant_id"], name: "index_companies_on_consultant_id"
    t.index ["shared_service_id"], name: "index_companies_on_shared_service_id"
  end

  create_table "contact_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "startup_id"
    t.string "name"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "colour"
    t.index ["startup_id"], name: "index_contact_statuses_on_startup_id"
  end

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.string "company_name"
    t.bigint "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "company_id"
    t.uuid "contact_status_id"
    t.uuid "cloned_by_id"
    t.boolean "searchable"
    t.index ["cloned_by_id"], name: "index_contacts_on_cloned_by_id"
    t.index ["contact_status_id"], name: "index_contacts_on_contact_status_id"
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
  end

  create_table "departments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "document_templates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "file_url"
    t.bigint "template_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_document_templates_on_template_id"
    t.index ["user_id"], name: "index_document_templates_on_user_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "filename"
    t.text "remarks"
    t.date "date_signed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_url"
    t.bigint "user_id"
    t.bigint "workflow_action_id"
    t.uuid "workflow_id"
    t.string "aws_textract_job_id"
    t.json "aws_textract_data"
    t.uuid "document_template_id"
    t.uuid "folder_id"
    t.uuid "company_id"
    t.uuid "outlet_id"
    t.uuid "post_id"
    t.index ["folder_id"], name: "index_documents_on_folder_id"
    t.index ["outlet_id"], name: "index_documents_on_outlet_id"
    t.index ["post_id"], name: "index_documents_on_post_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
    t.index ["workflow_action_id"], name: "index_documents_on_workflow_action_id"
  end

  create_table "event_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id"
    t.uuid "event_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_event_categories_on_category_id"
    t.index ["event_id"], name: "index_event_categories_on_event_id"
  end

  create_table "event_types", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "colour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "event_type_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text "remarks"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "staffer_id"
    t.uuid "client_id"
    t.decimal "number_of_hours"
    t.uuid "company_id"
    t.uuid "department_id"
    t.index ["department_id"], name: "index_events_on_department_id"
    t.index ["staffer_id"], name: "index_events_on_staffer_id"
  end

  create_table "folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.text "remarks"
    t.bigint "user_id"
    t.uuid "company_id"
    t.index ["ancestry"], name: "index_folders_on_ancestry"
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "franchisees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "franchise_licensee"
    t.string "registered_address"
    t.date "commencement_date"
    t.date "expiry_date"
    t.integer "renewal_period_freq_unit"
    t.integer "renewal_period_freq_value"
    t.uuid "company_id"
    t.index ["company_id"], name: "index_franchisees_on_company_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
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

  create_table "investments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id"
    t.uuid "startup_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "invoice_identifier"
    t.date "invoice_date"
    t.date "due_date"
    t.json "line_items", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "line_amount_type"
    t.integer "invoice_type"
    t.string "xero_invoice_id"
    t.string "invoice_reference"
    t.string "xero_contact_id"
    t.string "xero_contact_name"
    t.string "currency"
    t.integer "status"
    t.decimal "total"
    t.bigint "user_id"
    t.uuid "workflow_id"
    t.string "remarks"
    t.uuid "company_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "notable_type"
    t.uuid "notable_id"
    t.text "content"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "workflow_action_id"
    t.boolean "approved"
    t.string "remark"
    t.index ["user_id"], name: "index_notes_on_user_id"
    t.index ["workflow_action_id"], name: "index_notes_on_workflow_action_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "key", null: false
    t.string "group_type"
    t.bigint "group_id"
    t.integer "group_owner_id"
    t.string "notifier_type"
    t.bigint "notifier_id"
    t.text "parameters"
    t.datetime "opened_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_owner_id"], name: "index_notifications_on_group_owner_id"
    t.index ["group_type", "group_id"], name: "index_notifications_on_group_type_and_group_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["notifier_type", "notifier_id"], name: "index_notifications_on_notifier_type_and_notifier_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
  end

  create_table "outlets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "contact"
    t.string "report_url"
    t.uuid "company_id"
    t.uuid "franchisee_id"
    t.index ["company_id"], name: "index_outlets_on_company_id"
    t.index ["franchisee_id"], name: "index_outlets_on_franchisee_id"
  end

  create_table "outlets_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "website_url"
    t.date "established_date"
    t.string "contact"
    t.decimal "annual_turnover_rate"
    t.integer "currency"
    t.text "description"
    t.json "contact_person_details"
    t.uuid "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.uuid "outlet_id"
    t.index ["company_id"], name: "index_outlets_users_on_company_id"
    t.index ["outlet_id"], name: "index_outlets_users_on_outlet_id"
    t.index ["user_id"], name: "index_outlets_users_on_user_id"
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "role_id"
    t.boolean "can_write"
    t.boolean "can_view"
    t.boolean "can_download"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "permissible_type"
    t.uuid "permissible_id"
    t.bigint "user_id"
    t.index ["permissible_type", "permissible_id"], name: "index_permissions_on_permissible_type_and_permissible_id"
    t.index ["role_id"], name: "index_permissions_on_role_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.uuid "company_id"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["company_id"], name: "index_posts_on_company_id"
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.uuid "company_id"
    t.index ["company_id"], name: "index_profiles_on_company_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "content"
    t.integer "question_type"
    t.integer "position"
    t.bigint "survey_section_id"
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
    t.bigint "user_id"
    t.uuid "company_id"
    t.index ["template_id"], name: "index_recurring_workflows_on_template_id"
    t.index ["user_id"], name: "index_recurring_workflows_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "next_reminder"
    t.boolean "repeat"
    t.integer "freq_value"
    t.integer "freq_unit"
    t.datetime "past_reminders", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "title"
    t.text "content"
    t.bigint "task_id"
    t.bigint "workflow_action_id"
    t.boolean "email"
    t.boolean "sms"
    t.boolean "slack"
    t.uuid "company_id"
    t.index ["task_id"], name: "index_reminders_on_task_id"
    t.index ["user_id"], name: "index_reminders_on_user_id"
    t.index ["workflow_action_id"], name: "index_reminders_on_workflow_action_id"
  end

  create_table "responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.bigint "question_id"
    t.bigint "choice_id"
    t.bigint "segment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "multiple_choices_array"
    t.index ["choice_id"], name: "index_responses_on_choice_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["segment_id"], name: "index_responses_on_segment_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "sections", force: :cascade do |t|
    t.string "section_name"
    t.integer "position"
    t.bigint "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_sections_on_template_id"
  end

  create_table "segments", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.bigint "survey_section_id"
    t.bigint "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_segments_on_survey_id"
    t.index ["survey_section_id"], name: "index_segments_on_survey_section_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.string "key", null: false
    t.boolean "subscribing", default: true, null: false
    t.boolean "subscribing_to_email", default: true, null: false
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "subscribed_to_email_at"
    t.datetime "unsubscribed_to_email_at"
    t.text "optional_targets"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_subscriptions_on_key"
    t.index ["target_type", "target_id", "key"], name: "index_subscriptions_on_target_type_and_target_id_and_key", unique: true
    t.index ["target_type", "target_id"], name: "index_subscriptions_on_target_type_and_target_id"
  end

  create_table "survey_sections", force: :cascade do |t|
    t.string "unique_name"
    t.string "display_name"
    t.integer "position"
    t.bigint "survey_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "multiple_response"
    t.index ["survey_template_id"], name: "index_survey_sections_on_survey_template_id"
  end

  create_table "survey_templates", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "survey_type"
    t.uuid "company_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
    t.text "remarks"
    t.bigint "user_id"
    t.bigint "survey_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "workflow_id"
    t.uuid "company_id"
    t.index ["survey_template_id"], name: "index_surveys_on_survey_template_id"
    t.index ["user_id"], name: "index_surveys_on_user_id"
    t.index ["workflow_id"], name: "index_surveys_on_workflow_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.uuid "taggable_id", default: -> { "gen_random_uuid()" }, null: false
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.string "instructions"
    t.integer "position"
    t.bigint "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.integer "deadline_day"
    t.boolean "set_reminder"
    t.bigint "role_id"
    t.integer "task_type"
    t.string "link_url"
    t.boolean "important"
    t.bigint "child_workflow_template_id"
    t.bigint "survey_template_id"
    t.uuid "document_template_id"
    t.bigint "user_id"
    t.integer "deadline_type"
    t.text "description"
    t.index ["child_workflow_template_id"], name: "index_tasks_on_child_workflow_template_id"
    t.index ["role_id"], name: "index_tasks_on_role_id"
    t.index ["section_id"], name: "index_tasks_on_section_id"
    t.index ["survey_template_id"], name: "index_tasks_on_survey_template_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "title"
    t.integer "business_model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.json "data_names", default: "[]"
    t.integer "workflow_type", default: 0
    t.integer "deadline_day"
    t.integer "deadline_type"
    t.integer "template_pattern"
    t.integer "freq_value"
    t.integer "freq_unit"
    t.date "next_workflow_date"
    t.date "start_date"
    t.date "end_date"
    t.uuid "company_id"
    t.integer "template_type"
    t.index ["slug"], name: "index_templates_on_slug", unique: true
  end

  create_table "topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subject_name"
    t.integer "status"
    t.integer "question_category"
    t.bigint "user_id"
    t.uuid "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "startup_id"
    t.bigint "assigned_user_id"
    t.uuid "document_id"
    t.index ["assigned_user_id"], name: "index_topics_on_assigned_user_id"
    t.index ["company_id"], name: "index_topics_on_company_id"
    t.index ["document_id"], name: "index_topics_on_document_id"
    t.index ["startup_id"], name: "index_topics_on_startup_id"
    t.index ["user_id"], name: "index_topics_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.integer "max_hours_per_week"
    t.string "nric"
    t.string "bank_name"
    t.string "bank_account_number"
    t.integer "bank_account_type"
    t.date "date_of_birth"
    t.text "remarks"
    t.string "bank_account_name"
    t.json "settings", default: [{"reminder_sms"=>"", "reminder_email"=>"true", "reminder_slack"=>"", "task_sms"=>"", "task_email"=>"true", "task_slack"=>"", "batch_sms"=>"", "batch_email"=>"true", "batch_slack"=>""}]
    t.string "stripe_customer_id"
    t.string "stripe_card_token"
    t.uuid "company_id"
    t.uuid "outlet_id"
    t.datetime "last_click_comm_hub"
    t.uuid "department_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["outlet_id"], name: "index_users_on_outlet_id"
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "workflow_actions", force: :cascade do |t|
    t.bigint "task_id"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deadline"
    t.integer "approved_by"
    t.bigint "assigned_user_id"
    t.integer "completed_user_id"
    t.text "remarks"
    t.uuid "workflow_id"
    t.integer "time_spent_mins"
    t.boolean "current_action", default: false
    t.uuid "company_id"
    t.boolean "notify_status", default: false
    t.index ["assigned_user_id"], name: "index_workflow_actions_on_assigned_user_id"
    t.index ["completed_user_id"], name: "index_workflow_actions_on_completed_user_id"
    t.index ["task_id"], name: "index_workflow_actions_on_task_id"
  end

  create_table "workflows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "template_id"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deadline"
    t.string "identifier"
    t.string "workflowable_type"
    t.bigint "workflowable_id"
    t.text "remarks"
    t.json "data", default: "[]"
    t.json "archive", default: []
    t.bigint "recurring_workflow_id"
    t.uuid "batch_id"
    t.bigint "workflow_action_id"
    t.string "slug"
    t.integer "total_time_mins", default: 0
    t.uuid "company_id"
    t.uuid "outlet_id"
    t.index ["batch_id"], name: "index_workflows_on_batch_id"
    t.index ["outlet_id"], name: "index_workflows_on_outlet_id"
    t.index ["recurring_workflow_id"], name: "index_workflows_on_recurring_workflow_id"
    t.index ["slug"], name: "index_workflows_on_slug", unique: true
    t.index ["template_id"], name: "index_workflows_on_template_id"
    t.index ["user_id"], name: "index_workflows_on_user_id"
    t.index ["workflow_action_id"], name: "index_workflows_on_workflow_action_id"
    t.index ["workflowable_type", "workflowable_id"], name: "index_workflows_on_workflowable_type_and_workflowable_id"
  end

  create_table "xero_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "company_id"
  end

  create_table "xero_line_items", force: :cascade do |t|
    t.string "item_code"
    t.string "description"
    t.integer "quantity"
    t.decimal "price"
    t.string "account"
    t.string "tax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "company_id"
  end

  create_table "xero_tracking_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "tracking_category_id"
    t.json "options"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "company_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allocations", "availabilities"
  add_foreign_key "allocations", "events"
  add_foreign_key "allocations", "users"
  add_foreign_key "availabilities", "users"
  add_foreign_key "batches", "companies"
  add_foreign_key "batches", "templates"
  add_foreign_key "batches", "users"
  add_foreign_key "categories", "departments"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "users"
  add_foreign_key "companies", "users", column: "associate_id"
  add_foreign_key "companies", "users", column: "consultant_id"
  add_foreign_key "companies", "users", column: "shared_service_id"
  add_foreign_key "contact_statuses", "companies", column: "startup_id"
  add_foreign_key "contacts", "companies"
  add_foreign_key "contacts", "companies", column: "cloned_by_id"
  add_foreign_key "contacts", "contact_statuses"
  add_foreign_key "contacts", "users", column: "created_by_id"
  add_foreign_key "departments", "companies"
  add_foreign_key "document_templates", "templates"
  add_foreign_key "document_templates", "users"
  add_foreign_key "documents", "companies"
  add_foreign_key "documents", "document_templates"
  add_foreign_key "documents", "folders"
  add_foreign_key "documents", "outlets"
  add_foreign_key "documents", "posts"
  add_foreign_key "documents", "users"
  add_foreign_key "documents", "workflow_actions"
  add_foreign_key "documents", "workflows"
  add_foreign_key "event_categories", "categories"
  add_foreign_key "event_categories", "events"
  add_foreign_key "events", "companies"
  add_foreign_key "events", "departments"
  add_foreign_key "events", "users", column: "staffer_id"
  add_foreign_key "folders", "companies"
  add_foreign_key "folders", "users"
  add_foreign_key "franchisees", "companies"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "users"
  add_foreign_key "invoices", "workflows"
  add_foreign_key "notes", "users"
  add_foreign_key "notes", "workflow_actions"
  add_foreign_key "outlets", "companies"
  add_foreign_key "outlets", "franchisees"
  add_foreign_key "outlets_users", "outlets"
  add_foreign_key "outlets_users", "users"
  add_foreign_key "permissions", "roles"
  add_foreign_key "permissions", "users"
  add_foreign_key "posts", "companies"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "profiles", "companies"
  add_foreign_key "questions", "survey_sections"
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
  add_foreign_key "segments", "survey_sections"
  add_foreign_key "segments", "surveys"
  add_foreign_key "survey_sections", "survey_templates"
  add_foreign_key "survey_templates", "companies"
  add_foreign_key "surveys", "companies"
  add_foreign_key "surveys", "survey_templates"
  add_foreign_key "surveys", "users"
  add_foreign_key "surveys", "workflows"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tasks", "document_templates"
  add_foreign_key "tasks", "roles"
  add_foreign_key "tasks", "sections"
  add_foreign_key "tasks", "survey_templates"
  add_foreign_key "tasks", "templates", column: "child_workflow_template_id"
  add_foreign_key "tasks", "users"
  add_foreign_key "templates", "companies"
  add_foreign_key "topics", "companies"
  add_foreign_key "topics", "companies", column: "startup_id"
  add_foreign_key "topics", "documents"
  add_foreign_key "topics", "users"
  add_foreign_key "topics", "users", column: "assigned_user_id"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "outlets"
  add_foreign_key "workflow_actions", "companies"
  add_foreign_key "workflow_actions", "tasks"
  add_foreign_key "workflow_actions", "users", column: "assigned_user_id"
  add_foreign_key "workflow_actions", "users", column: "completed_user_id"
  add_foreign_key "workflow_actions", "workflows"
  add_foreign_key "workflows", "batches"
  add_foreign_key "workflows", "companies"
  add_foreign_key "workflows", "outlets"
  add_foreign_key "workflows", "recurring_workflows"
  add_foreign_key "workflows", "templates"
  add_foreign_key "workflows", "users"
  add_foreign_key "workflows", "workflow_actions"
  add_foreign_key "xero_contacts", "companies"
  add_foreign_key "xero_line_items", "companies"
  add_foreign_key "xero_tracking_categories", "companies"
end
