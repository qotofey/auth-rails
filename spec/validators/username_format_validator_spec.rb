# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsernameFormatValidator, type: :validator do
  let(:record) { UserCredential.new }

  describe '#validate_each' do
    context 'when username is nil' do
      it 'is valid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, nil) }.not_to raise_error
        expect(record.errors[:login]).to be_empty
      end
    end

    context 'when username is empty' do
      it 'is valid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, '') }.not_to raise_error
        expect(record.errors[:login]).to be_empty
      end
    end

    context 'when username contains only letters' do
      it 'is valid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'username') }.not_to raise_error
        expect(record.errors[:login]).to be_empty
      end
    end

    context 'when username contains only digits' do
      it 'is valid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, '123456') }.not_to raise_error
        expect(record.errors[:login]).to be_empty
      end
    end

    context 'when username contains letters and digits' do
      it 'is valid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'user123') }.not_to raise_error
        expect(record.errors[:login]).to be_empty
      end
    end

    context 'when username contains underscore' do
      it 'is invalid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'user_name') }.not_to raise_error
        expect(record.errors[:login]).to include('может содержать только буквы и цифры английского алфавита')
      end
    end

    context 'when username contains dash' do
      it 'is invalid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'user-name') }.not_to raise_error
        expect(record.errors[:login]).to include('может содержать только буквы и цифры английского алфавита')
      end
    end

    context 'when username contains dot' do
      it 'is invalid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'user.name') }.not_to raise_error
        expect(record.errors[:login]).to include('может содержать только буквы и цифры английского алфавита')
      end
    end

    context 'when username contains cyrillic characters' do
      it 'is invalid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'пользователь') }.not_to raise_error
        expect(record.errors[:login]).to include('может содержать только буквы и цифры английского алфавита')
      end
    end

    context 'when username contains special characters' do
      it 'is invalid' do
        validator = described_class.new(attributes: :login)
        expect { validator.validate_each(record, :login, 'user@name') }.not_to raise_error
        expect(record.errors[:login]).to include('может содержать только буквы и цифры английского алфавита')
      end
    end
  end
end
