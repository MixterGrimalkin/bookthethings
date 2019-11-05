FactoryBot.define do
  factory :provider do
    description { Faker::Company.catch_phrase }
    web_link { Faker::Internet.url }
    photo_url { Faker::Company.logo }
    # needs company
    # needs user
  end
end