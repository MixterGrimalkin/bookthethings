FactoryBot.define do
  factory :location do
    street_address { Faker::Address.street_address }
    postcode { Faker::Address.postcode }
  end
end