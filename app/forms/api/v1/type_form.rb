# frozen_string_literal: true

module Api
  module V1
    class TypeForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :type

      validates :type, presence: true, inclusion: { in: %w[users] }
    end
  end
end
