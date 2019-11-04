require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should belong_to :user }
  it { should have_many :companies }
  it { should have_many :locations }
  it { should have_many :bookings }
end
