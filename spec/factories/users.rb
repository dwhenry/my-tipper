FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User_#{n}" }
    sequence(:email) { |n| "user_#{n}@test.com" }
    password { 'Revival123' }
    password_confirmation { 'Revival123' }
    email_notification { false }
  end
end
