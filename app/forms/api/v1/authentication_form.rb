
module Api
  module V1
    class AuthenticationForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :username, :password

      validates :username, presence: true
      validates :password, presence: true
    end
  end
end
