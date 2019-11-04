FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    slug { Faker::Internet.slug }
    description { Faker::Lorem.sentence }
    login_html { 'Company login html' }
  end
end