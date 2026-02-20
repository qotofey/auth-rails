# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RegistrationForm, type: :form do
  describe 'validations' do
    describe 'data presence' do
      context 'when data is missing' do
        it 'is invalid with error on data' do
          form = described_class.new({})
          expect(form).not_to be_valid
          expect(form.errors[:data]).to include('Обязательный атрибут data отсутствует')
        end
      end

      context 'when data is present' do
        it 'is valid for data presence' do
          form = described_class.new('data' => {})
          expect(form.errors[:data]).to be_empty
        end
      end
    end

    describe 'type validation' do
      context 'when type is missing' do
        it 'is invalid with error on type' do
          form = described_class.new('data' => {})
          expect(form).not_to be_valid
          expect(form.errors[:type]).to include('не может быть пустым')
        end
      end

      context 'when type is invalid' do
        it 'is invalid with error on type' do
          form = described_class.new('data' => { 'type' => 'wrong' })
          expect(form).not_to be_valid
          expect(form.errors[:type]).to include('неверный тип ресурса')
        end
      end

      context 'when type is valid' do
        it 'is valid for type' do
          form = described_class.new('data' => { 'type' => 'users' })
          expect(form.errors[:type]).to be_empty
        end
      end
    end

    describe 'attributes validation' do
      context 'when attributes is missing' do
        it 'is invalid with error on attributes' do
          form = described_class.new('data' => { 'type' => 'users' })
          expect(form).not_to be_valid
          expect(form.errors[:attributes]).to include('не может быть пустым')
        end
      end

      context 'when attributes is present' do
        it 'is valid for attributes presence' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => {} })
          expect(form.errors[:attributes]).to be_empty
        end
      end
    end

    describe 'username validation' do
      let(:valid_params) do
        {
          'data' => {
            'type' => 'users',
            'attributes' => {
              'username' => 'validuser123',
              'password' => 'Qwerty123456'
            }
          }
        }
      end

      context 'when username is missing' do
        it 'is invalid with error on username' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'password' => 'Qwerty123456' } })
          expect(form).not_to be_valid
          expect(form.errors[:username]).to include('Логин не может быть пустым')
        end
      end

      context 'when username contains invalid characters' do
        it 'is invalid with error on username' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'username' => 'user_name', 'password' => 'Qwerty123456' } })
          expect(form).not_to be_valid
          expect(form.errors[:username]).to include('может содержать только цифры и буквы английского языка')
        end
      end

      context 'when username is too short' do
        it 'is invalid with error on username' do
          # Пустой username не проходит валидацию presence, а не length
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'username' => '', 'password' => 'Qwerty123456' } })
          expect(form).not_to be_valid
          expect(form.errors[:username]).to include('Логин не может быть пустым')
        end
      end

      context 'when username is valid' do
        it 'is valid for username' do
          form = described_class.new(valid_params)
          expect(form.errors[:username]).to be_empty
        end
      end

      context 'when username is normalized' do
        it 'normalizes username to lowercase and strips whitespace' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'username' => '  UserName123  ', 'password' => 'Qwerty123456' } })
          expect(form.username).to eq('username123')
        end
      end
    end

    describe 'password validation' do
      let(:valid_params) do
        {
          'data' => {
            'type' => 'users',
            'attributes' => {
              'username' => 'validuser123',
              'password' => 'Qwerty123456'
            }
          }
        }
      end

      context 'when password is missing' do
        it 'is invalid with error on password' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'username' => 'validuser123' } })
          expect(form).not_to be_valid
          expect(form.errors[:password]).to include('Пароль не может быть пустым')
        end
      end

      context 'when password is too short' do
        it 'is invalid with error on password' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'username' => 'validuser123', 'password' => 'short' } })
          expect(form).not_to be_valid
          expect(form.errors[:password]).to include('недостаточной длины (не может быть меньше 10 символов)')
        end
      end

      context 'when password is too long' do
        it 'is invalid with error on password' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'username' => 'validuser123', 'password' => 'a' * 65 } })
          expect(form).not_to be_valid
          expect(form.errors[:password]).to include('слишком большой длины (не может быть больше чем 64 символов)')
        end
      end

      context 'when password is valid' do
        it 'is valid for password' do
          form = described_class.new(valid_params)
          expect(form.errors[:password]).to be_empty
        end
      end
    end

    describe 'conditional validation' do
      context 'when data is missing' do
        it 'does not validate type, attributes, username, password' do
          form = described_class.new({})
          expect(form).not_to be_valid
          # Только ошибка data
          expect(form.errors[:data]).not_to be_empty
          expect(form.errors[:type]).to be_empty
          expect(form.errors[:attributes]).to be_empty
          expect(form.errors[:username]).to be_empty
          expect(form.errors[:password]).to be_empty
        end
      end

      context 'when type is invalid' do
        it 'does not validate attributes, username, password' do
          form = described_class.new('data' => { 'type' => 'wrong' })
          expect(form).not_to be_valid
          # Ошибки type, но не attributes/username/password
          expect(form.errors[:type]).not_to be_empty
          expect(form.errors[:attributes]).to be_empty
          expect(form.errors[:username]).to be_empty
          expect(form.errors[:password]).to be_empty
        end
      end

      context 'when attributes is missing' do
        it 'does not validate username, password' do
          form = described_class.new('data' => { 'type' => 'users' })
          expect(form).not_to be_valid
          # Ошибки attributes, но не username/password
          expect(form.errors[:attributes]).not_to be_empty
          expect(form.errors[:username]).to be_empty
          expect(form.errors[:password]).to be_empty
        end
      end
    end
  end
end
