require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should validate_presence_of :name }
  it { should have_many :providers }
  it { should have_many :bookings }
  it { should have_many :rates}
end
