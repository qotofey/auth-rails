# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UpdateUserRequestForm, type: :form do
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

      context 'when attributes is empty' do
        it 'is invalid with error on attributes' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => {} })
          expect(form).not_to be_valid
          expect(form.errors[:attributes]).to include('должен содержать хотя бы одно поле для обновления')
        end
      end

      context 'when attributes has fields' do
        it 'is valid for attributes presence' do
          form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'name' => 'Иван' } })
          expect(form.errors[:attributes]).to be_empty
        end
      end
    end

    describe 'extracted_attributes' do
      it 'extracts attributes correctly' do
        form = described_class.new('data' => { 'type' => 'users', 'attributes' => { 'name' => 'Иван', 'middleName' => 'Иванович' } })
        expect(form.extracted_attributes).to eq({
          name: 'Иван',
          middle_name: 'Иванович',
          last_name: nil,
          gender: nil,
          birth_date: nil
        })
      end
    end

    describe 'conditional validation' do
      context 'when data is missing' do
        it 'does not validate type, attributes' do
          form = described_class.new({})
          expect(form).not_to be_valid
          expect(form.errors.keys).to eq([ :data ])
        end
      end

      context 'when type is invalid' do
        it 'does not validate attributes fields' do
          form = described_class.new('data' => { 'type' => 'wrong', 'attributes' => { 'name' => 'Иван' } })
          expect(form).not_to be_valid
          expect(form.errors.keys).to eq([ :type ])
        end
      end

      context 'when attributes is missing' do
        it 'does not validate attributes fields' do
          form = described_class.new('data' => { 'type' => 'users' })
          expect(form).not_to be_valid
          expect(form.errors.keys).to eq([ :attributes ])
        end
      end
    end
  end
end
