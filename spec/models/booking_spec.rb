require 'rails_helper'

RSpec.describe Booking, type: :model do
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should belong_to :service }
  it { should belong_to :provider }
  it { should belong_to :customer }
  it { should belong_to :location }
end
