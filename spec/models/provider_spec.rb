require 'rails_helper'

RSpec.describe Provider, type: :model do
  it { should belong_to :user }
  it { should validate_presence_of :company }
  it { should belong_to :company }
  it { should have_many :services }
  it { should have_many :locations }
  it { should have_many :bookings }
  it { should have_many :rates }
  it { should have_many :availabilities }
end
