FactoryBot.define do
  factory :workflow_action do
    company
    workflow
    task

    association :assigned_user, factory: :user

    completed { false }
    deadline { Faker::Date.between(Date.current, 1.month.from_now) }

    factory :completed_workflow_action do
      association :completed_user, factory: :user
      completed { true }
    end
  end
end
