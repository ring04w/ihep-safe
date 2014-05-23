FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    factory :admin do
      role 1
    end
    factory :superadmin do
      role 2
    end
  end
  factory :machine do
    ip "127.0.0.1"
    user
  end
end
