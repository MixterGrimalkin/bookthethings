require 'rails_helper'

RSpec.shared_examples 'services validator' do
  let(:nameless_service_params) {
    result = valid_service_params
    result['name'] = nil
    result
  }
  let(:bad_length_service_params) {
    result = valid_service_params
    result['min_length'] = 120
    result['max_length'] = 60
    result
  }
  let(:bad_resolution_service_params) {
    result = valid_service_params
    result['booking_resolution'] = 45
    result
  }
  context 'when service name is missing' do
    let(:params) { nameless_service_params.to_json }
    it 'responds with 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
      expect(response.body).to match(/Name can't be blank/)
    end
  end
  context 'when service length range is invalid' do
    let(:params) { bad_length_service_params.to_json }
    it 'responds with 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
      expect(response.body).to match(/Length range can't be negative/)
    end
  end
  context 'when service booking resolution is invalid' do
    let(:params) { bad_resolution_service_params.to_json }
    it 'responds with 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
      expect(response.body).to match(/Length must be a multiple of resolution/)
    end
  end
end

RSpec.describe 'Services API', type: :request do

  before {
    @provider = create(:provider)

    @service_one = create(:service)
    @service_two = create(:service)
    @provider.services << @service_one
    @provider.services << @service_two

    @service_three = create(:service)
  }

  let(:service_id) { 0 }
  let(:valid_service_params) {
    {
        'name' => 'My Lovely Service',
        'description' => 'Fetlocks Blowing in the Wind',
        'min_length' => 60,
        'max_length' => 120,
        'booking_resolution' => 60
    }
  }
  let(:params) { {}.to_json }

  # List Services
  describe 'GET /services' do
    before {
      get '/services', params: {}, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it 'responds with 200 (OK)' do
        expect(response.status).to eq(200)
      end
      it 'returns two services' do
        expect(json.size).to eq(2)
        expect(compare_services(json[0], @service_one)).to be(true)
        expect(compare_services(json[1], @service_two)).to be(true)
      end
    end
  end

  # Create a Service
  describe 'POST /services' do
    before {
      post '/services', params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it_behaves_like 'services validator'
      context 'when service is valid' do
        let(:params) { valid_service_params.to_json }
        it 'responds with 200' do
          expect(response.status).to eq(200)
          expect(json['message']).to match(/Service created/)
        end
        it 'returns the ID of the new service' do
          expect(json['id']).to eq(Service.last.id)
        end
        it 'creates a service' do
          expect(Service.count).to eq(4)
          service = Service.last
          expect(compare_services(valid_service_params, service, [:id])).to be (true)
        end
        it 'adds service to provider' do
          expect(@provider.services.count).to eq(3)
          expect(@provider.services.last.id).to eq(Service.last.id)
        end
      end
    end
  end

  # Update an existing Service
  describe 'PUT /services/:service_id' do
    before {
      put "/services/#{service_id}", params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      context 'when service does not exist' do
        it 'responds with 404 (not found)' do
          expect(response.status).to eq(404)
          expect(response.body).to match(/Couldn't find Service/)
        end
      end
      context 'when service exists but is not provided' do
        let(:service_id) { @service_three.id }
        it 'responds with 400 (bad request)' do
          # Provider can only update services that they provide
          expect(response.status).to eq(400)
          expect(response.body).to match(/Service not provided/)
        end
      end
      context 'when service exists and is provided' do
        let(:service_id) { @service_one.id }
        it_behaves_like 'services validator'
        context 'when service is valid' do
          let(:params) { valid_service_params.to_json }
          it 'responds with 200 (OK)' do
            expect(response.status).to eq(200)
            expect(response.body).to match(/OK/)
          end
          it 'updates the service' do
            @service_one.reload
            expect(compare_services(valid_service_params, @service_one, [:id])).to be (true)
          end
        end
      end
    end
  end


  # Add an existing Service to Provider
  describe 'POST /services/add/:service_id' do
    before {
      post "/services/add/#{service_id}", params: {}, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      context 'when service does not exist' do
        it 'responds with 404 (not found)' do
          expect(response.status).to eq(404)
          expect(response.body).to match(/Couldn't find Service/)
        end
      end
      context 'when service exists but is already provided' do
        let(:service_id) { @service_one.id }
        it 'responds with 400 (bad request)' do
          expect(response.status).to eq(400)
          expect(response.body).to match(/Service already provided/)
        end
      end
      context 'when service exists and is not already provided' do
        let(:service_id) { @service_three.id }
        it 'responds with 200 (OK)' do
          expect(response.status).to eq(200)
          expect(response.body).to match(/Service added/)
        end
        it 'adds service to provider' do
          expect(@provider.services.count).to eq(3)
          expect(@provider.services.last.id).to eq(@service_three.id)
        end
      end
    end
  end

  # Remove a Service from a Provider
  describe 'POST /services/remove/:service_id' do
    before {
      post "/services/remove/#{service_id}", params: {}, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      context 'when service does not exist' do
        it 'responds with 404 (not found)' do
          expect(response.status).to eq(404)
          expect(response.body).to match(/Couldn't find Service/)
        end
      end
      context 'when service exists but is not provided' do
        let(:service_id) { @service_three.id }
        it 'responds with 400 (bad request)' do
          expect(response.status).to eq(400)
          expect(response.body).to match(/Service not provided/)
        end
      end
      context 'when service exists and is provided' do
        let(:service_id) { @service_one.id }
        it 'responds with 200 (OK)' do
          expect(response.status).to eq(200)
          expect(response.body).to match('Service removed')
        end
        it 'removes service from provider' do
          expect(@provider.services.count).to eq(1)
          expect(@provider.services.first.id).to eq(@service_two.id)
        end
      end
    end
  end

end