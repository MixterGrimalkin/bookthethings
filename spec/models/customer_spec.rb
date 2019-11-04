require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should have_many :companies }
  it { should have_many :locations }
  it { should have_many :bookings }
  it 'registers customer with company' do
    company = Company.create!(name: 'Acme Co.', slug: 'acme')
    customer = Customer.create!(name: 'Jim McBob', email: 'jim@bob.com')

    expect(CustomerRegistration.count).to eql 0
    expect(customer.registered_with? company).to eql(false)

    customer.register_with(company)

    expect(CustomerRegistration.count).to eql 1
    expect(customer.registered_with? company).to eql(true)
  end
end
