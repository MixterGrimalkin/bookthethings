require 'rails_helper'

RSpec.describe 'Locations API', type: :request do

  before {
    @locations = create_list(:location, 5)

    @customer = create(:customer)
    @customer.locations << @locations[0]
    @customer.locations << @locations[1]

    @provider = create(:provider)
    @provider.locations << @locations[1]
    @provider.locations << @locations[2]

    @both_user = create(:user)
    @both_customer = create(:customer, user: @both_user)
    @both_customer.locations << @locations[2]
    @both_customer.locations << @locations[3]
    @both_provider = create(:provider, user: @both_user)
    @both_provider.locations << @locations[3]
    @both_provider.locations << @locations[4]

    @plain_user = create(:user)

    @test_street_address = '123 Nowhere Road, London'
    @test_postcode = 'N88AA'
  }

  context 'GET /locations' do
    before {
      get '/locations', params: {}, headers: headers
    }
    context 'when not logged in' do
      let(:headers) { invalid_headers }
      it 'responds with 422' do
        expect(response.status).to eq(422)
        expect(response.body).to match(/Missing token/)
      end
    end
    context 'when logged in as plain user' do
      let(:headers) { valid_headers(@plain_user) }
      it 'responds with empty payload' do
        expect(response.status).to eq(200)
        expect(json).to be_empty
      end
    end
    context 'when logged in as customer' do
      let(:headers) { valid_headers(@customer.user) }
      it 'returns customer locations' do
        expect(response.status).to eq(200)
        expect(json.size).to eq(1)
        expect(json['customer'].size).to eq(2)
        expect(compare_locations(json['customer'][0], @locations[0])).to be true
        expect(compare_locations(json['customer'][1], @locations[1])).to be true
        expect(json['provider']).to be nil
      end
    end
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it 'returns provider locations' do
        expect(response.status).to eq(200)
        expect(json.size).to eq(1)
        expect(json['provider'].size).to eq(2)
        expect(compare_locations(json['provider'][0], @locations[1])).to be true
        expect(compare_locations(json['provider'][1], @locations[2])).to be true
        expect(json['customer']).to be nil
      end
    end
    context 'when logged in as both' do
      let(:headers) { valid_headers(@both_user) }
      it 'returns both sets of locations' do
        expect(response.status).to eq(200)
        expect(json.size).to eq(2)
        expect(json['customer'].size).to eq(2)
        expect(compare_locations(json['customer'][0], @locations[2])).to be true
        expect(compare_locations(json['customer'][1], @locations[3])).to be true
        expect(json['provider'].size).to eq(2)
        expect(compare_locations(json['provider'][0], @locations[3])).to be true
        expect(compare_locations(json['provider'][1], @locations[4])).to be true
      end
    end
  end

  context 'POST /locations/create' do
    before {
      post '/locations/create', params: params, headers: headers
    }
    let(:params) {
      {street_address: @test_street_address, postcode: @test_postcode}.to_json
    }
    context 'when not logged in' do
      let(:headers) { invalid_headers }
      it 'responds with 422' do
        expect(response.status).to eq(422)
        expect(response.body).to match(/Missing token/)
      end
    end
    context 'when logged in' do
      let(:headers) { valid_headers(@plain_user) }
      context 'when parameters are valid' do
        it 'creates location and returns ID' do
          expect(response.status).to eq(200)
          expect(Location.count).to eq(6)
          expect(json['message']).to match(/Location created/)
          location = Location.last
          expect(json['id']).to eq(location.id)
          expect(location.street_address).to eq(@test_street_address)
          expect(location.postcode).to eq(@test_postcode)
        end
      end
      context 'when parameters are missing' do
        let(:params) { {}.to_json }
        it 'responds with 422' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Street address can't be blank/)
          expect(response.body).to match(/Postcode can't be blank/)
        end
      end
    end
  end

  context 'POST /locations/update/:id' do
    before {
      post "/locations/update/#{location_id}", params: params, headers: headers
    }
    let(:location_id) { @locations[0].id }
    let(:params) {
      {street_address: @test_street_address, postcode: @test_postcode}.to_json
    }
    context 'when not logged in' do
      let(:headers) { invalid_headers }
      it 'responds with 422' do
        expect(response.status).to eq(422)
        expect(response.body).to match(/Missing token/)
      end
    end
    context 'when logged in' do
      let(:headers) { valid_headers(@plain_user) }
      context 'when location exists' do
        it 'updates location' do
          expect(response.status).to eq(200)
          location = Location.find(@locations[0].id)
          expect(location.street_address).to eq(@test_street_address)
          expect(location.postcode).to eq(@test_postcode)
        end
      end
      context 'when location does not exist' do
        let(:location_id) { 1000 }
        it 'reponds with 404' do
          expect(response.status).to eq(404)
          expect(response.body).to match(/Couldn't find Location/)
        end
        it 'does not update location' do
          location = Location.find(@locations[0].id)
          expect(location.street_address).to eq(@locations[0].street_address)
          expect(location.postcode).to eq(@locations[0].postcode)
        end
      end
    end
  end

  context 'POST /locations/link-customer/:id' do
    before {
      post "/locations/link-customer/#{location_id}", params: {}, headers: headers
    }
    let(:location_id) { @locations[4].id }
    context 'when not logged in' do
      let(:headers) { invalid_headers }
      it 'responds with 422' do
        expect(response.status).to eq(422)
        expect(response.body).to match(/Missing token/)
      end
    end
    context 'when logged in as customer' do
      let(:headers) { valid_headers(@customer.user) }
      context 'when location does not exist' do
        let(:location_id) { 1000 }
        it 'responds with 404' do
          expect(response.status).to eq(404)
          expect(response.body).to match(/Couldn't find Location/)
        end
      end
      context 'when location already added' do
        let(:location_id) { @locations[0].id }
        it 'responds with 400' do
          expect(response.status).to eq(400)
          expect(json['message']).to match(/Location already added/)
        end
        it 'does not add location' do
          @customer.reload
          expect(@customer.locations.size).to eq(2)
        end
      end
      context 'when location not already added' do
        it 'adds location to customer' do
          expect(response.status).to eq(200)
          expect(json['message']).to match(/Added customer location/)
          @customer.reload
          expect(@customer.locations.size).to eq(3)
          location = @customer.locations.last
          expect(location.id).to eq(@locations[4].id)
        end
      end
    end
    context 'when logged in as non-customer' do
      let(:headers) { valid_headers(@provider.user) }
      it 'responds with 404' do
        expect(response.status).to eq(404)
        expect(response.body).to match(/User is not a customer/)
      end
    end
  end

  context 'POST /locations/link-provider/:id' do
    before {
      post "/locations/link-provider/#{location_id}", params: {}, headers: headers
    }
    let(:location_id) { @locations[4].id }
    context 'when not logged in' do
      let(:headers) { invalid_headers }
      it 'responds with 422' do
        expect(response.status).to eq(422)
        expect(response.body).to match(/Missing token/)
      end
    end
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      context 'when location does not exist' do
        let(:location_id) { 1000 }
        it 'responds with 404' do
          expect(response.status).to eq(404)
          expect(response.body).to match(/Couldn't find Location/)
        end
      end
      context 'when location already added' do
        let(:location_id) { @locations[1].id }
        it 'responds with 400' do
          expect(response.status).to eq(400)
          expect(json['message']).to match(/Location already added/)
        end
        it 'does not add location' do
          @provider.reload
          expect(@provider.locations.size).to eq(2)
        end
      end
      context 'when location not already added' do
        it 'adds location to provider' do
          expect(response.status).to eq(200)
          expect(json['message']).to match(/Added provider location/)
          @provider.reload
          expect(@provider.locations.size).to eq(3)
          location = @provider.locations.last
          expect(location.id).to eq(@locations[4].id)
        end
      end
    end
    context 'when logged in as non-provider' do
      let(:headers) { valid_headers(@customer.user) }
      it 'responds with 404' do
        expect(response.status).to eq(404)
        expect(response.body).to match(/User is not a provider/)
      end
    end
  end

end