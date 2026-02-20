# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'POST /api/v1/user' do
    context 'when data is missing' do
      it 'returns 422 with error on data' do
        post '/api/v1/user', params: {}, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].size).to eq(1)
        expect(json['errors'][0]['source']['pointer']).to eq('/data')
      end
    end

    context 'when data is empty' do
      it 'returns 422 with error on type' do
        post '/api/v1/user', params: { data: {} }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/type' }).to be true
      end
    end

    context 'when type is invalid' do
      it 'returns 422 with error on type' do
        post '/api/v1/user', params: { data: { type: 'wrong' } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/type' }).to be true
      end
    end

    context 'when attributes is missing' do
      it 'returns 422 with error on attributes' do
        post '/api/v1/user', params: { data: { type: 'users' } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes' }).to be true
      end
    end

    context 'when username contains invalid characters' do
      it 'returns 422 with error on username' do
        post '/api/v1/user', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'user_name',
              password: 'Qwerty123456'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes/username' }).to be true
      end
    end

    context 'when password is too short' do
      it 'returns 422 with error on password' do
        post '/api/v1/user', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'validuser123',
              password: 'short'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes/password' }).to be true
      end
    end

    context 'when request is valid' do
      it 'creates a user and returns 201' do
        post '/api/v1/user', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'newuser123',
              password: 'Qwerty123456'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['type']).to eq('users')
        expect(json['data']['attributes']['username']).to eq('newuser123')
      end
    end

    context 'when username is duplicate' do
      it 'returns 422 with error on username' do
        # Create user first
        post '/api/v1/user', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'duplicateuser',
              password: 'Qwerty123456'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:created)

        # Try to create duplicate
        post '/api/v1/user', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'duplicateuser',
              password: 'Qwerty123456'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes/username' }).to be true
      end
    end
  end

  describe 'GET /api/v1/user' do
    let(:user) { User.create! }
    let(:credential) { UserCredential.create!(user: user, login: 'testuser', kind: :username) }
    let(:password) { UserPassword.create!(user: user, password: 'Qwerty123456') }

    context 'when not authenticated' do
      it 'returns 401' do
        get '/api/v1/user', as: :json
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['errors'][0]['status']).to eq('401')
      end
    end

    context 'when authenticated' do
      let(:token) { JwtEncoder.new(user.id).call }

      it 'returns user data' do
        get '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['type']).to eq('users')
      end
    end
  end

  describe 'PUT /api/v1/user' do
    let(:user) { User.create! }
    let(:credential) { UserCredential.create!(user: user, login: 'testuser', kind: :username) }
    let(:password) { UserPassword.create!(user: user, password: 'Qwerty123456') }
    let(:token) { JwtEncoder.new(user.id).call }

    context 'when not authenticated' do
      it 'returns 401' do
        put '/api/v1/user', params: {
          data: {
            type: 'users',
            attributes: {
              name: 'Иван'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when data is missing' do
      it 'returns 422 with error on data' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {}, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data' }).to be true
      end
    end

    context 'when type is invalid' do
      it 'returns 422 with error on type' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {
          data: {
            type: 'wrong',
            attributes: {
              name: 'Иван'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/type' }).to be true
      end
    end

    context 'when attributes is empty' do
      it 'returns 422 with error on attributes' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {
          data: {
            type: 'users',
            attributes: {}
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes' }).to be true
      end
    end

    context 'when name contains numbers' do
      it 'returns 422 with error on name' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {
          data: {
            type: 'users',
            attributes: {
              name: 'Иван123'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes/name' }).to be true
      end
    end

    context 'when gender is invalid' do
      it 'returns 422 with error on gender' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {
          data: {
            type: 'users',
            attributes: {
              gender: 'other'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes/gender' }).to be true
      end
    end

    context 'when request is valid' do
      it 'updates user and returns 200' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {
          data: {
            type: 'users',
            attributes: {
              name: 'Иван'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Иван')
      end
    end

    context 'when name has multiple dashes' do
      it 'normalizes name to single dashes' do
        put '/api/v1/user', headers: { 'Authorization' => "Bearer #{token}" }, params: {
          data: {
            type: 'users',
            attributes: {
              name: 'Иван--Петр'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Иван-Петр')
      end
    end
  end
end
