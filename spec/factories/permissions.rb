FactoryBot.define do
  factory :permission do
    folder { nil }
    role { nil }
    can_write { false }
    can_view { false }
    can_download { false }
  end
end
