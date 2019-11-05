FactoryBot.define do
  factory :service do
    name { Faker::Company.industry }
    description { Faker::Company.catch_phrase }
  end
end