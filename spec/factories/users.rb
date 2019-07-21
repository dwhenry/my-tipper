FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Name_#{n}" }
    sequence(:email) { |n| "name_#{n}@test.com" }
    password { 'Revival123' }
    password_confirmation { 'Revival123' }
    email_notification { false }
  end
end
