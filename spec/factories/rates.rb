FactoryBot.define do
  factory :rate do
    day { Faker::Number.between(from: 0, to: 6) }
    start_time {
      Faker::Time.between(from: Time.parse('08:00'), to: Time.parse('12:00'))
    }
    end_time {
      Faker::Time.between(from: Time.parse('12:00'), to: Time.parse('17:00'))
    }
    cost_amount { Faker::Number.number(digits: 4 ) }
    cost_per { [30,60].shuffle.first }
    service { create(:service) }
  end
end

