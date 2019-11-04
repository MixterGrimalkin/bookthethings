require 'rails_helper'

RSpec.describe Availability, type: :model do
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should belong_to :provider }
  it { should belong_to :base_location }
  it { should have_many :locations }
  it { should have_many :services }
  it { should have_many :rates }
end
