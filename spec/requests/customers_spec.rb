require 'rails_helper'

RSpec.describe 'Customers API', type: :request do

  context 'get customer information' do

    before do
      @locations = create_list(:location, 5)
      @companies = create_list(:company, 5)

      @customer_one = create(:customer)
      @customer_one.locations << @locations[0]
      @customer_one.companies << @companies[0]
      @customer_one.companies << @companies[1]

      @customer_two = create(:customer)
      @customer_two.locations << @locations[1]
      @customer_two.locations << @locations[2]
      @customer_two.companies << @companies[1]
      @customer_two.companies << @companies[2]
      @customer_two.companies << @companies[3]

      @non_customer_user = create(:user)
    end

    context 'GET /customers/details' do
      before {
        get '/customers/details', params: {}, headers: headers
      }
      context 'when not logged in' do
        let(:headers) { invalid_headers }
        it 'responds with 422' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Missing token/)
        end
      end
      context 'when logged in as non-customer user' do
        let(:headers) { valid_headers(@non_customer_user) }
        it 'responds with 401' do
          expect(response.status).to eq(401)
          expect(response.body).to match(/User is not a customer/)
        end
      end
      context 'when logged in as Customer One' do
        let(:headers) { valid_headers(@customer_one.user) }
        it 'returns customer details' do
          expect(response.status).to eq(200)
          expect(compare_users(json, @customer_one.user)).to be true
        end
      end
      context 'when logged in as Customer Two' do
        let(:headers) { valid_headers(@customer_two.user) }
        it 'returns customer details' do
          expect(response.status).to eq(200)
          expect(compare_users(json, @customer_two.user)).to be true
        end
      end
    end

    context 'GET /customers/companies' do
      before {
        get '/customers/companies', params: {}, headers: headers
      }
      context 'when not logged in' do
        let(:headers) { invalid_headers }
        it 'responds with 422' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Missing token/)
        end
      end
      context 'when logged in as non-customer user' do
        let(:headers) { valid_headers(@non_customer_user) }
        it 'responds with 401' do
          expect(response.status).to eq(401)
          expect(response.body).to match(/User is not a customer/)
        end
      end
      context 'when logged in as Customer One' do
        let(:headers) { valid_headers(@customer_one.user) }
        it 'returns companies' do
          expect(response.status).to eq(200)
          expect(json.size).to eq(2)
          expect(compare_companies(json[0], @companies[0])).to be true
          expect(compare_companies(json[1], @companies[1])).to be true
        end
      end
      context 'when logged in as Customer Two' do
        let(:headers) { valid_headers(@customer_two.user) }
        it 'returns companies' do
          expect(response.status).to eq(200)
          expect(json.size).to eq(3)
          expect(compare_companies(json[0], @companies[1])).to be true
          expect(compare_companies(json[1], @companies[2])).to be true
          expect(compare_companies(json[2], @companies[3])).to be true
        end
      end
    end

    context 'GET /customers/locations' do
      before {
        get '/customers/locations', params: {}, headers: headers
      }
      context 'when not logged in' do
        let(:headers) { invalid_headers }
        it 'responds with 422' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Missing token/)
        end
      end
      context 'when logged in as non-customer user' do
        let(:headers) { valid_headers(@non_customer_user) }
        it 'responds with 401' do
          expect(response.status).to eq(401)
          expect(response.body).to match(/User is not a customer/)
        end
      end
      context 'when logged in as Customer One' do
        let(:headers) { valid_headers(@customer_one.user) }
        it 'returns customer locations' do
          expect(response.status).to eq(200)
          expect(json.size).to eq(1)
          expect(compare_locations(json[0], @locations[0])).to be true
        end
      end
      context 'when logged in as Customer Two' do
        let(:headers) { valid_headers(@customer_two.user) }
        it 'returns customer locations' do
          expect(response.status).to eq(200)
          expect(json.size).to eq(2)
          expect(compare_locations(json[0], @locations[1])).to be true
          expect(compare_locations(json[1], @locations[2])).to be true
        end
      end
    end
  end

  context 'request and enable users to customers' do

    let(:invite_key) { 'abc456def0' }

    let(:existing_customer) { create(:customer) }
    let(:requested_customer) { create(:customer, invite_key: invite_key) }
    let(:simple_user) { create(:user) }

    context 'POST /customers/request' do
      before {
        post '/customers/request', params: {}, headers: headers
      }
      context 'when not logged in' do
        let(:headers) { invalid_headers }
        it 'responds with 422' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Missing token/)
        end
      end
      context 'when logged in as existing customer' do
        let(:headers) { valid_headers(existing_customer.user) }
        it 'responds with 400' do
          expect(response.status).to eq(400)
          expect(response.body).to match(/User is already a customer/)
        end
      end
      context 'when logged in as simple user' do
        let(:headers) { valid_headers(simple_user) }
        it 'saves and responds with invite key' do
          expect(response.status).to eq(200)
          expect(json['message']).to match(/Requested Customer status for User/)
          new_key = json['invite_key']
          expect(new_key).not_to be_nil
          expect(new_key).to eq(Customer.find_by(user: simple_user).invite_key)
        end
      end
      context 'when logged in as requested customer' do
        let(:headers) { valid_headers(requested_customer.user) }
        it 'saves and responds with new invite key' do
          expect(response.status).to eq(200)
          expect(json['message']).to match(/Requested Customer status for User/)
          new_key = json['invite_key']
          expect(new_key).not_to be_nil
          expect(new_key).not_to eq(invite_key)
          expect(new_key).to eq(Customer.find(requested_customer.id).invite_key)
        end
      end
    end

    context 'POST /customers/enable' do
      before {
        post '/customers/enable', params: {invite_key: invite_key_param}.to_json, headers: headers
      }
      let(:invite_key_param) { invite_key }
      context 'when not logged in' do
        let(:headers) { invalid_headers }
        it 'responds with 422' do
          expect(response.status).to eq(422)
          expect(response.body).to match(/Missing token/)
        end
      end
      context 'when logged in as existing customer' do
        let(:headers) { valid_headers(existing_customer.user) }
        it 'responds with 400' do
          expect(response.status).to eq(400)
          expect(response.body).to match(/User is already a customer/)
        end
      end
      context 'when logged in as simple user' do
        let(:headers) { valid_headers(simple_user) }
        it 'responds with 401' do
          expect(response.status).to eq(401)
          expect(response.body).to match(/User is not a customer/)
        end
      end
      context 'when logged in as requested customer' do
        let(:headers) { valid_headers(requested_customer.user) }
        context 'when use wrong invite key' do
          let(:invite_key_param) { invite_key.reverse }
          it 'responds with 400' do
            expect(response.status).to eq(400)
            expect(response.body).to match(/Invalid invite key/)
            expect(Customer.find(requested_customer.id).invite_key).to eq(invite_key)
          end
        end
        context 'when use correct invite key' do
          it 'enables customer' do
            expect(response.status).to eq(200)
            expect(json['message']).to match(/User is now a customer/)
            expect(Customer.find(requested_customer.id).invite_key).to be_nil
          end
        end
      end
    end

  end

end
