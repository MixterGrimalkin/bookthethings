require 'rails_helper'

RSpec.describe 'Services API', type: :request do

  before {
    # A User who is not a Provider
    @plain_user = create(:user)

    # A User who is a Provider
    @provider_user = create(:user)
    @provider = create(:provider, user: @provider_user)

    # Two services that she provides
    @service_one = create(:service)
    @service_two = create(:service)
    @provider.services << @service_one
    @provider.services << @service_two

    # One service she does NOT provider
    @service_three = create(:service)
  }

  # List Services
  describe 'GET /services' do
    before {
      # Call API
      get '/services', params: {}, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider_user) }
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

  let(:service_id) { 0 }
  let(:test_service_name) { 'My New Service' }
  let(:test_service_description) { 'It is very lovely' }
  let(:params) {
    {name: test_service_name, description: test_service_description}.to_json
  }

  # Create a Service
  describe 'POST /services' do
    before {
      post '/services', params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider_user) }
      context 'when service name is missing' do
        let(:params) { {}.to_json }
        # database validation will throw an error if name is blank
        it 'responds with 422 (unprocessable entity)' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Name can't be blank/)
        end
      end
      context 'when service name is provided' do
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
          expect(service.name).to eq(test_service_name)
          expect(service.description).to eq(test_service_description)
        end
        it 'adds service to provider' do
          expect(@provider.services.count).to eq(3)
          service = @provider.services.last
          expect(service.name).to eq(test_service_name)
          expect(service.description).to eq(test_service_description)
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
      let(:headers) { valid_headers(@provider_user) }
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
        context 'when name is missing' do
          let(:params) { {name: nil, description: nil}.to_json }
          # database validation will throw an error if name is blank
          it 'responds with 422 (unprocessable entity)' do
            expect(response.status).to eq(422)
            expect(response.body).to match(/Name can't be blank/)
          end
        end
        context 'when name is present' do
          it 'responds with 200 (OK)' do
            expect(response.status).to eq(200)
            expect(response.body).to match(/OK/)
          end
          it 'updates the service' do
            @service_one.reload
            expect(@service_one.name).to eq(test_service_name)
            expect(@service_one.description).to eq(test_service_description)
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
      let(:headers) { valid_headers(@provider_user) }
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
          service = @provider.services.last
          expect(service.id).to eq(@service_three.id)
          expect(service.name).to eq(@service_three.name)
          expect(service.description).to eq(@service_three.description)
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
      let(:headers) { valid_headers(@provider_user) }
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