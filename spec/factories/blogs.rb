FactoryBot.define do
  factory :blog do
    title { Faker::Book.title }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    views { 0 }
    status { 0 } # assuming enum default
    association :user
  end
end