FactoryBot.define do
  factory :task do
    instructions Faker::Lorem.sentence
    task_type 'instructions'
    sequence(:position) { |n| n}
    section
    image_url Faker::Placeholdit.image

    factory :upload_file_task do
      task_type 'upload_file'
    end

    factory :approval_task do
      task_type 'approval'
    end

    factory :download_file_task do
      task_type 'download_file'
      document_template
    end

    factory :visit_link_task do
      task_type 'visit_link'
      link_url Faker::Internet.url
    end

    factory :task_with_reminder do
      days_to_complete 2
      set_reminder true
    end
  end
end
