# frozen_string_literal: true

module Api
  module V1
    class RegistrationForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :login, :password

      validates :login, presence: true, length: { maximum: 64 }
      validates :password, length: { in: 10..128 }
    end
  end
end
