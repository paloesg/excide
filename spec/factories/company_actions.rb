FactoryBot.define do
  factory :company_action do
    company
    workflow
    task

    association :assigned_user, factory: :user

    completed false
    deadline Faker::Date.between(Date.today, 1.month.from_now)

    factory :completed_company_action do
      association :completed_user, factory: :user
      completed true
    end
  end
end
