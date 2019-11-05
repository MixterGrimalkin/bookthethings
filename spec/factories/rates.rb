FactoryBot.define do
  factory :rate do
    name { Faker::Marketing.buzzwords }
    cost_amount { Faker::Number.number(digits: 4 ) }
    cost_per { [30,60].shuffle.first }
    min_length { [60,120].shuffle.first }
    # needs provider
    # needs service
  end
end

