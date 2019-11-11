require 'rails_helper'
require 'time'

RSpec.describe Rate, type: :model do
  it { should validate_presence_of :day }
  it { should validate_presence_of :cost_amount }
  it { should validate_presence_of :cost_per }
  it { should validate_presence_of :start_time }
  it { should validate_presence_of :end_time }
  it { should validate_presence_of :service }
  it { should belong_to :service }
  it 'should ensure start time is before end time' do
    expect(build(
               :rate,
               start_time: Time.parse('13:00'),
               end_time: Time.parse('14:00')).valid?).to be(true)
    expect(build(
               :rate,
               start_time: Time.parse('14:00'),
               end_time: Time.parse('13:00')).valid?).to be(false)
    expect(build(
               :rate,
               start_time: Time.parse('13:00'),
               end_time: Time.parse('13:00')).valid?).to be(false)
  end
  it 'should ensure time range is at least min length for service' do
    service = create(:service, min_length: 60)
    expect(build(
               :rate,
               service: service,
               start_time: Time.parse('13:00'),
               end_time: Time.parse('14:00')).valid?).to be(true)
    expect(build(
               :rate,
               service: service,
               start_time: Time.parse('13:00'),
               end_time: Time.parse('13:30')).valid?).to be(false)
  end

end
