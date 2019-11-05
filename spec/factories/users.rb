FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'binglybob' }
    phone { Faker::PhoneNumber.phone_number }
  end
end