# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    # sequence ensures each user has a unique email to avoid validation errors
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end