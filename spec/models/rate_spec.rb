require 'rails_helper'

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
               start_time: time('13:00'),
               end_time: time('14:00')).valid?).to be(true)
    expect(build(
               :rate,
               service: service,
               start_time: time('13:00'),
               end_time: time('13:30')).valid?).to be(false)
  end
  it 'should return correct day name' do
    rate = create(:rate, day: 1)
    expect(rate.day_name).to eq('Monday')
  end
  it 'should return correct minutes values' do
    rate = create(:rate, start_time: time('13:00'), end_time: time('13:30'))
    expect(rate.start_time_minutes).to eq(780)
    expect(rate.end_time_minutes).to eq(810)
    expect(rate.length_minutes).to eq(30)
  end
  it 'should find correct rate for given service and time' do
    service_a = create(:service)
    service_b = create(:service)
    rate_a_1 = create(:rate, day: 1, start_time: time('13:00'), end_time: time('14:00'), service: service_a)
    rate_a_2 = create(:rate, day: 1, start_time: time('14:00'), end_time: time('15:00'), service: service_a)
    rate_b_1 = create(:rate, day: 1, start_time: time('13:30'), end_time: time('14:30'), service: service_b)
    expect(Rate.find_rate_at(service_a, 1, time('13:45'))).to eq(rate_a_1)
    expect(Rate.find_rate_at(service_a, 1, time('14:45'))).to eq(rate_a_2)
    expect(Rate.find_rate_at(service_a, 1, time('14:00'))).to eq(rate_a_2)
    expect(Rate.find_rate_at(service_b, 1, time('14:00'))).to eq(rate_b_1)
    expect(Rate.find_rate_at(service_a, 1, time('18:00'))).to be_nil
  end
  it 'should detect time clashes' do
    service = create(:service)
    rate = create(:rate, day: 1, start_time: time('12:00'), end_time: time('15:00'), service: service)

    expect(Rate.available?(service, 1, time('09:00'), time('11:00'))).to be(true)
    expect(Rate.available?(service, 1, time('16:00'), time('18:00'))).to be(true)
    expect(Rate.available?(service, 1, time('10:00'), time('12:00'))).to be(true)
    expect(Rate.available?(service, 1, time('15:00'), time('17:00'))).to be(true)
    expect(Rate.available?(service, 1, time('15:00'), time('17:00'), rate.id)).to be(true)

    expect(Rate.available?(service, 1, time('12:00'), time('15:00'))).to be(false)
    expect(Rate.available?(service, 1, time('11:00'), time('13:00'))).to be(false)
    expect(Rate.available?(service, 1, time('13:00'), time('14:00'))).to be(false)
    expect(Rate.available?(service, 1, time('14:00'), time('16:00'))).to be(false)
    expect(Rate.available?(service, 1, time('11:00'), time('16:00'))).to be(false)
    expect(Rate.available?(service, 1, time('11:00'), time('16:00'), rate.id)).to be(true)
  end

end
