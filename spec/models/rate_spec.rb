require 'rails_helper'

RSpec.describe Rate, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :cost_amount }
  it { should validate_presence_of :cost_per }
  it { should belong_to :service }
  it { should belong_to :provider }
end
