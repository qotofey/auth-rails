# frozen_string_literal: true

module Api
  module V1
    class UserSerializer
      include JSONAPI::Serializer

      set_type :users
      set_key_transform :camel_lower

      attribute :username, if: proc { |obj|
        obj.username.present?
      } do |obj|
        obj.username
      end

      attributes :name, :middle_name, :last_name, :gender, :birth_date
    end
  end
end
