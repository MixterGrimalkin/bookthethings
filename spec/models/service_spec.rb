require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should validate_presence_of :name }
  it { should have_many :providers }
  it { should have_many :bookings }
  it { should have_many :rates}
  it 'ensures length range is valid' do
    expect(build(:service, min_length: nil, max_length: nil).valid?).to be(true)
    expect(build(:service, min_length: 60, max_length: nil).valid?).to be(true)
    expect(build(:service, min_length: nil, max_length: 60).valid?).to be(true)
    expect(build(:service, min_length: 60, max_length: 60).valid?).to be(true)
    expect(build(:service, min_length: 60, max_length: 120).valid?).to be(true)

    expect(build(:service, min_length: 0, max_length: nil).valid?).to be(false)
    expect(build(:service, min_length: nil, max_length: 0).valid?).to be(false)
    expect(build(:service, min_length: 120, max_length: 60).valid?).to be(false)
  end
  it 'ensures booking resolution is valid' do
    expect(build(:service, min_length: 30, max_length: 60, booking_resolution: nil).valid?).to be(true)
    expect(build(:service, min_length: 30, max_length: 60, booking_resolution: 30).valid?).to be(true)
    expect(build(:service, min_length: 30, max_length: 60, booking_resolution: 60).valid?).to be(false)
  end
end
