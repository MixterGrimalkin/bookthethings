require 'rails_helper'

RSpec.describe 'Customers API', type: :request do

  before do
    @users = create_list(:user, 3)
    @locations = create_list(:location, 5)
    @companies = create_list(:company, 5)

    @customer_one = Customer.create(user: @users[0])
    @customer_one.locations << @locations[0]
    @customer_one.companies << @companies[0]
    @customer_one.companies << @companies[1]

    @customer_two = Customer.create(user: @users[1])
    @customer_two.locations << @locations[1]
    @customer_two.locations << @locations[2]
    @customer_two.companies << @companies[1]
    @customer_two.companies << @companies[2]
    @customer_two.companies << @companies[3]
  end

  context 'GET /customers/details' do
    before { get '/customers/details', params: {}, headers: headers }

    context 'when not logged in' do
      let(:headers) { invalid_headers }
      it 'returns status 422' do
        expect(response.status).to eq(422)
      end
      it 'returns an error message' do
        expect(response.body).to match(/Missing token/)
      end
    end

    context 'when logged in as non-customer user' do
      let(:headers) { valid_headers(@users[2]) }
      it 'returns status 404' do
        expect(response.status).to eq(404)
      end
      it 'returns an error message' do
        expect(response.body).to match(/User is not a customer/)
      end
    end

    context 'when logged in as Customer One' do
      let(:headers) { valid_headers(@customer_one.user) }
      it 'returns status 200' do
        expect(response.status).to eq(200)
      end
      it 'returns customer details' do
        expect(compare_users(@customer_one.user, json)).to be true
      end
      it 'returns customer locations' do
        locations = json['locations']
        expect(locations.size).to eq(1)
        expect(compare_locations(@locations[0], locations[0])).to be true
      end
      it 'returns customer registered companies' do
        companies = json['registered_with_companies']
        expect(companies.size).to eq(2)
        expect(compare_companies(@companies[0], companies[0])).to be true
        expect(compare_companies(@companies[1], companies[1])).to be true
      end
      pending 'returns customer bookings'
    end

    context 'when logged in as Customer Two' do
      let(:headers) { valid_headers(@customer_two.user) }
      it 'returns status 200' do
        expect(response.status).to eq(200)
      end
      it 'returns customer details' do
        expect(compare_users(@customer_two.user, json)).to be true
      end
      it 'returns customer locations' do
        locations = json['locations']
        expect(locations.size).to eq(2)
        expect(compare_locations(@locations[1], locations[0])).to be true
        expect(compare_locations(@locations[2], locations[1])).to be true
      end
      it 'returns customer registered companies' do
        companies = json['registered_with_companies']
        expect(companies.size).to eq(3)
        expect(compare_companies(@companies[1], companies[0])).to be true
        expect(compare_companies(@companies[2], companies[1])).to be true
        expect(compare_companies(@companies[3], companies[2])).to be true
      end
      pending 'returns customer bookings'
    end

  end

  # TODO endpoint to set user up as customer

end