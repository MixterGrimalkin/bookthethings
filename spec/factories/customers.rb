FactoryBot.define do
  factory :customer do
    user { create(:user) }
  end
end
