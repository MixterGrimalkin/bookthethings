require 'rails_helper'

RSpec.describe Location, type: :model do
  it { should validate_presence_of :street_address }
  it { should validate_presence_of :postcode }
  it { should have_many :providers }
  it { should have_many :customers }
  it { should have_many :bookings }
end
