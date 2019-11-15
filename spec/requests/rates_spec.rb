require 'rails_helper'

RSpec.shared_examples 'service resource' do
  context 'when service does not exist' do
    let(:service_id) { 0 }
    it 'responds with 404 (not found)' do
      expect(response.status).to eq(404)
      expect(response.body).to match(/Couldn't find Service/)
    end
  end
  context 'when service exists but is not provided' do
    let(:service_id) { @service_c.id }
    it 'responds with 400 (bad request)' do
      expect(response.status).to eq(400)
      expect(response.body).to match(/Service not provided/)
    end
  end
end

RSpec.shared_examples 'rate resource' do
  context 'when rate does not exist' do
    it 'responds with 404 (not found)' do
      expect(response.status).to eq(404)
      expect(response.body).to match(/Couldn't find Rate/)
    end
  end
  context 'when rate exists but not in right service' do
    let(:rate_id) { @rate_b_one.id }
    it 'responds with 404 (not found)' do
      expect(response.status).to eq(404)
      expect(response.body).to match(/Couldn't find Rate/)
    end
  end
end

RSpec.shared_examples 'rate validator' do
  let(:service_id) { @service_a.id }
  context 'when rate is missing all fields' do
    let(:params) {
      {
          'day' => nil,
          'start_time' => nil,
          'end_time' => nil,
          'cost_amount' => nil,
          'cost_per' => nil
      }.to_json
    }
    it 'returns 422 (unprocessable entitiy)' do
      expect(response.status).to eq(422)
    end
    it 'returns error messages for all missing fields' do
      expect(response.body).to match(/Day can't be blank/)
      expect(response.body).to match(/Start time can't be blank/)
      expect(response.body).to match(/End time can't be blank/)
      expect(response.body).to match(/Cost amount can't be blank/)
      expect(response.body).to match(/Cost per can't be blank/)
    end
  end
  context 'when rate times are backwards' do
    let(:params) {
      {
          'day' => 1,
          'start_time' => time('14:00'),
          'end_time' => time('12:00'),
          'cost_amount' => 1000,
          'cost_per' => 60
      }.to_json
    }
    it 'returns 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
    end
    it 'returns error message' do
      expect(response.body).to match(/Start time can't be after end time/)
    end
  end
  context 'when rate times are too short' do
    let(:params) {
      {
          'day' => 1,
          'start_time' => time('10:00'),
          'end_time' => time('10:30'),
          'cost_amount' => 1000,
          'cost_per' => 60
      }.to_json
    }
    it 'returns 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
    end
    it 'returns error message' do
      expect(response.body).to match(/Rate window must encompass minimum service booking/)
    end
  end
  context 'when times clash with existing rate' do
    let(:params) {
      {
          'day' => 2,
          'start_time' => time('10:00'),
          'end_time' => time('12:00'),
          'cost_amount' => 1000,
          'cost_per' => 60
      }.to_json
    }
    it 'returns 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
    end
    it 'returns error message' do
      expect(response.body).to match(/Requested time not available/)
    end
  end
end

RSpec.describe 'Rates API', type: :request do

  before {
    @service_a = create(:service, min_length: 60)
    @rate_a_one = create(:rate,
                         day: 1,
                         start_time: time('08:00'),
                         end_time: time('10:00'),
                         service: @service_a)
    @rate_a_two = create(:rate,
                         day: 2,
                         start_time: time('08:30'),
                         end_time: time('10:30'),
                         service: @service_a)

    @service_b = create(:service)
    @rate_b_one = create(:rate,
                         day: 1,
                         start_time: time('10:00'),
                         end_time: time('12:00'),
                         service: @service_b)

    @provider = create(:provider)
    @provider.services << @service_a
    @provider.services << @service_b

    @service_c = create(:service)
    @rate_c_one = create(:rate,
                         day: 1,
                         start_time: time('10:30'),
                         end_time: time('12:30'),
                         service: @service_c)
    @rate_c_two = create(:rate,
                         day: 2,
                         start_time: time('08:00'),
                         end_time: time('10:00'),
                         service: @service_c)
  }

  let(:valid_rate) {
    {
        'day' => 1,
        'start_time' => time('10:00'),
        'end_time' => time('12:00'),
        'cost_amount' => 1000,
        'cost_per' => 60
    }
  }

  let(:service_id) { 0 }
  let(:rate_id) { 0 }
  let(:params) { {}.to_json }

  describe 'GET /services/rates' do
    before {
      get '/services/rates', params: {}, headers: headers
    }
    it_behaves_like 'authenticated controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it 'responds with 200 (OK)' do
        expect(response.status).to eq(200)
      end
      it 'returns two services with rates' do
        expect(json.size).to eq(2)
        expect(compare_services(json[0], @service_a)).to be(true)
        expect(compare_services(json[1], @service_b)).to be(true)

        rates_a = json[0]['rates']
        expect(rates_a.size).to eq(2)
        expect(compare_rates(rates_a[0], @rate_a_one, [:service_id])).to be(true)
        expect(compare_rates(rates_a[1], @rate_a_two, [:service_id])).to be(true)

        rates_b = json[1]['rates']
        expect(rates_b.size).to eq(1)
        expect(compare_rates(rates_b[0], @rate_b_one, [:service_id])).to be(true)
      end
    end
  end

  describe 'GET /services/:service_id/rates' do
    before {
      get "/services/#{service_id}/rates", params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it_behaves_like 'service resource'
      context 'when service valid' do
        let(:service_id) { @service_a.id }
        it 'responds with 200 (OK)' do
          expect(response.status).to eq(200)
        end
        it 'returns two rates' do
          expect(json.size).to eq(2)
          expect(compare_rates(json[0], @rate_a_one)).to be(true)
          expect(compare_rates(json[1], @rate_a_two)).to be(true)
        end
      end
    end
  end

  describe 'POST /services/:service_id/rates' do
    before {
      post "/services/#{service_id}/rates", params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it_behaves_like 'service resource'
      it_behaves_like 'rate validator'
      context 'when request is valid' do
        let(:service_id) { @service_a.id }
        let(:params) { valid_rate.to_json }
        it 'responds with 200 (OK)' do
          expect(response.status).to eq(200)
          expect(response.body).to match(/Rate created/)
        end
        it 'creates a rate record' do
          expect(Rate.count).to eq(6)
          rate = Rate.last
          expect(compare_rates(valid_rate, rate, [:id, :service_id, :start_time, :end_time])).to be(true)
          expect(rate.service).to eq(@service_a)
          expect(rate.start_time_minutes).to eq(valid_rate['start_time'].seconds_since_midnight / 60)
          expect(rate.end_time_minutes).to eq(valid_rate['end_time'].seconds_since_midnight / 60)
        end
        it 'returns ID of new rate' do
          expect(json['id']).to eq(Rate.last.id)
        end
      end
    end
  end

  describe 'PUT /services/:service_id/rates/:rate_id' do
    before {
      put "/services/#{service_id}/rates/#{rate_id}", params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it_behaves_like 'service resource'
      context 'when service valid' do
        let(:service_id) { @service_a.id }
        it_behaves_like 'rate resource'
        context 'when rate exists in right service' do
          let(:rate_id) { @rate_a_one.id }
          it_behaves_like 'rate validator'
          context 'when rate request is valid' do
            let(:params) { valid_rate.to_json }
            it 'responds with 200 (OK)' do
              expect(response.status).to eq(200)
              expect(response.body).to match(/Rate updated/)
            end
            it 'updates the rate record' do
              @rate_a_one.reload
              expect(compare_rates(valid_rate, @rate_a_one, [:id, :service_id, :start_time, :end_time])).to be(true)
              expect(@rate_a_one.service).to eq(@service_a)
              expect(@rate_a_one.start_time_minutes).to eq(valid_rate['start_time'].seconds_since_midnight / 60)
              expect(@rate_a_one.end_time_minutes).to eq(valid_rate['end_time'].seconds_since_midnight / 60)
            end
          end
        end
      end
    end
  end

  describe 'DELETE /services/:service_id/rates/:rate_id' do
    before {
      delete "/services/#{service_id}/rates/#{rate_id}", params: params, headers: headers
    }
    it_behaves_like 'authenticated controller'
    it_behaves_like 'provider-only controller'
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it_behaves_like 'service resource'
      context 'when service valid' do
        let(:service_id) { @service_a.id }
        it_behaves_like 'rate resource'
        context 'when rate exists in right service' do
          let(:rate_id) { @rate_a_one.id }
          it 'responds with 200 (OK)' do
            expect(response.status).to eq(200)
            expect(response.body).to match(/Rate deleted/)
          end
          it 'deletes the rate' do
            expect(Rate.count).to eq(4)
            expect(Rate.exists?(rate_id)).to be(false)
            expect(Service.find(service_id).rates.count).to eq(1)
          end
        end
      end
    end
  end

end