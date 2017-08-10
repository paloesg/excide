# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170810062130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "line_1"
    t.string   "line_2"
    t.string   "postal_code"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "addresses", ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id", using: :btree

  create_table "choices", force: :cascade do |t|
    t.text     "content"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "choices_questions", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "choice_id",   null: false
  end

  add_index "choices_questions", ["question_id", "choice_id"], name: "index_choices_questions_on_question_id_and_choice_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "industry"
    t.integer  "company_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.string   "image_url"
    t.text     "description"
    t.string   "title"
    t.string   "linkedin_url"
    t.string   "aasm_state"
    t.string   "ssic_code"
    t.date     "financial_year_end"
  end

  add_index "companies", ["user_id"], name: "index_companies_on_user_id", using: :btree

  create_table "company_actions", force: :cascade do |t|
    t.integer  "task_id"
    t.boolean  "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deadline"
    t.integer  "company_id"
  end

  add_index "company_actions", ["company_id"], name: "index_company_actions_on_company_id", using: :btree
  add_index "company_actions", ["task_id"], name: "index_company_actions_on_task_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "filename"
    t.string   "file_type"
    t.integer  "company_id"
    t.date     "date_signed"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "file_url"
  end

  add_index "documents", ["company_id"], name: "index_documents_on_company_id", using: :btree

  create_table "enquiries", force: :cascade do |t|
    t.string   "name"
    t.string   "contact"
    t.string   "email"
    t.text     "comments"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "source"
    t.boolean  "responded",  default: false
  end

  create_table "experiences", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "title"
    t.string   "company"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "experiences", ["profile_id"], name: "index_experiences_on_profile_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.string   "headline"
    t.text     "summary"
    t.string   "industry"
    t.string   "specialties"
    t.string   "image_url"
    t.string   "linkedin_url"
    t.string   "location"
    t.string   "country_code"
    t.string   "display_name"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "project_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "parent_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.integer  "project_category_id"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "budget"
    t.integer  "budget_type"
    t.text     "remarks"
    t.integer  "status"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "company_id"
    t.text     "criteria"
    t.integer  "grant"
  end

  add_index "projects", ["company_id"], name: "index_projects_on_company_id", using: :btree

  create_table "proposals", force: :cascade do |t|
    t.integer  "profile_id"
    t.text     "qualifications"
    t.integer  "amount"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "file_url"
    t.integer  "project_id"
    t.integer  "status"
  end

  add_index "proposals", ["profile_id"], name: "index_proposals_on_profile_id", using: :btree
  add_index "proposals", ["project_id"], name: "index_proposals_on_project_id", using: :btree

  create_table "qualifications", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "institution"
    t.string   "title"
    t.integer  "year_obtained"
    t.text     "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "qualifications", ["profile_id"], name: "index_qualifications_on_profile_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text     "content"
    t.integer  "question_type"
    t.integer  "position"
    t.integer  "section_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "questions", ["section_id"], name: "index_questions_on_section_id", using: :btree

  create_table "reminders", force: :cascade do |t|
    t.datetime "next_reminder"
    t.boolean  "repeat"
    t.integer  "freq_value"
    t.integer  "freq_unit"
    t.datetime "past_reminders",    default: [],              array: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "title"
    t.text     "content"
    t.integer  "task_id"
    t.integer  "company_action_id"
  end

  add_index "reminders", ["company_action_id"], name: "index_reminders_on_company_action_id", using: :btree
  add_index "reminders", ["company_id"], name: "index_reminders_on_company_id", using: :btree
  add_index "reminders", ["task_id"], name: "index_reminders_on_task_id", using: :btree
  add_index "reminders", ["user_id"], name: "index_reminders_on_user_id", using: :btree

  create_table "responses", force: :cascade do |t|
    t.text     "content"
    t.integer  "question_id"
    t.integer  "choice_id"
    t.integer  "segment_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "responses", ["choice_id"], name: "index_responses_on_choice_id", using: :btree
  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["segment_id"], name: "index_responses_on_segment_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "unique_name"
    t.string   "display_name"
    t.integer  "position"
    t.integer  "template_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "sections", ["template_id"], name: "index_sections_on_template_id", using: :btree

  create_table "segments", force: :cascade do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "section_id"
    t.integer  "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "segments", ["section_id"], name: "index_segments_on_section_id", using: :btree
  add_index "segments", ["survey_id"], name: "index_segments_on_survey_id", using: :btree

  create_table "surveys", force: :cascade do |t|
    t.string   "title"
    t.text     "remarks"
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "template_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "surveys", ["company_id"], name: "index_surveys_on_company_id", using: :btree
  add_index "surveys", ["template_id"], name: "index_surveys_on_template_id", using: :btree
  add_index "surveys", ["user_id"], name: "index_surveys_on_user_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "instructions"
    t.integer  "position"
    t.integer  "section_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "image_url"
    t.integer  "days_to_complete"
    t.boolean  "set_reminder"
  end

  add_index "tasks", ["section_id"], name: "index_tasks_on_section_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "title"
    t.integer  "business_model"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "slug"
  end

  add_index "templates", ["slug"], name: "index_templates_on_slug", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "contact_number"
    t.boolean  "allow_contact"
    t.boolean  "agree_terms"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "aasm_state"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "workflows", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "template_id"
    t.boolean  "completed"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deadline"
  end

  add_index "workflows", ["company_id"], name: "index_workflows_on_company_id", using: :btree
  add_index "workflows", ["template_id"], name: "index_workflows_on_template_id", using: :btree
  add_index "workflows", ["user_id"], name: "index_workflows_on_user_id", using: :btree

  add_foreign_key "companies", "users"
  add_foreign_key "company_actions", "companies"
  add_foreign_key "company_actions", "tasks"
  add_foreign_key "documents", "companies"
  add_foreign_key "experiences", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "projects", "companies"
  add_foreign_key "proposals", "profiles"
  add_foreign_key "proposals", "projects"
  add_foreign_key "qualifications", "profiles"
  add_foreign_key "questions", "sections"
  add_foreign_key "reminders", "companies"
  add_foreign_key "reminders", "company_actions"
  add_foreign_key "reminders", "tasks"
  add_foreign_key "reminders", "users"
  add_foreign_key "responses", "choices"
  add_foreign_key "responses", "questions"
  add_foreign_key "responses", "segments"
  add_foreign_key "sections", "templates"
  add_foreign_key "segments", "sections"
  add_foreign_key "segments", "surveys"
  add_foreign_key "surveys", "companies"
  add_foreign_key "surveys", "templates"
  add_foreign_key "surveys", "users"
  add_foreign_key "tasks", "sections"
  add_foreign_key "workflows", "companies"
  add_foreign_key "workflows", "templates"
  add_foreign_key "workflows", "users"
end
