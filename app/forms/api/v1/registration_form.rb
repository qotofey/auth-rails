# frozen_string_literal: true

require "action_controller"

module Api
  module V1
    class RegistrationForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :data, :type, :attributes, :username, :password

      # Валидации для data
      validate :data_presence
      validate :data_must_be_hash

      # Валидации для type (только если data присутствует)
      validate :validate_type, if: :data_present?

      # Валидации для attributes (только если data присутствует)
      validate :validate_attributes, if: :data_present?

      # Валидации для username/password (только если data, type, attributes присутствуют и type корректен)
      validate :validate_username_and_password, if: :data_type_attributes_and_type_valid?

      def data_present?
        !data.nil?
      end

      def data_type_attributes_and_type_valid?
        data_present? && !type.nil? && !attributes.nil? && errors[:type].empty?
      end

      def initialize(params)
        @data = params[:data] || params["data"]
        @type = params[:type] || params["type"] || @data&.[]("type") || @data&.[](:type)
        @attributes = params[:attributes] || params["attributes"] || @data&.[]("attributes") || @data&.[](:attributes)
        @username = (@attributes&.[]("username") || @attributes&.[](:username))&.to_s&.strip&.downcase
        @password = params[:password] || params["password"] || @attributes&.[]("password") || @attributes&.[](:password)
      end

      private

      def data_presence
        if data.nil?
          errors.add(:data, :blank, message: I18n.t("activemodel.errors.messages.data_blank"))
        end
      end

      def data_must_be_hash
        return if data.nil?
        return if data.is_a?(Hash) || data.is_a?(ActionController::Parameters)

        errors.add(:data, :invalid_format)
      end

      def validate_type
        if type.nil?
          errors.add(:type, :blank, message: "не может быть пустым")
        elsif type.is_a?(Hash) || type.is_a?(ActionController::Parameters)
          errors.add(:type, :invalid_format, message: "должен быть строкой")
        elsif type != "users"
          errors.add(:type, :inclusion, message: "неверный тип ресурса")
        end
      end

      def validate_attributes
        if attributes.nil?
          errors.add(:attributes, :blank, message: "не может быть пустым")
        elsif !attributes.is_a?(Hash) && !attributes.is_a?(ActionController::Parameters)
          errors.add(:attributes, :invalid_format, message: "должен быть объектом")
        end
      end

      def validate_username_and_password
        # Username presence
        if username.nil?
          errors.add(:username, :blank, message: "Логин не может быть пустым")
        else
          # Username length
          if username.length < 1
            errors.add(:username, :too_short, message: "недостаточной длины (не может быть меньше 1 символов)")
          elsif username.length > 64
            errors.add(:username, :too_long, message: "слишком большой длины (не может быть больше чем 64 символов)")
          end

          # Username format
          unless username.match?(/\A[a-zA-Z0-9]+\z/)
            errors.add(:username, :invalid_format, message: "может содержать только цифры и буквы английского языка")
          end

          # Username unique (handled by validator)
        end

        # Password presence
        if password.nil?
          errors.add(:password, :blank, message: "Пароль не может быть пустым")
        else
          # Password length
          if password.length < 10
            errors.add(:password, :too_short, message: "недостаточной длины (не может быть меньше 10 символов)")
          elsif password.length > 64
            errors.add(:password, :too_long, message: "слишком большой длины (не может быть больше чем 64 символов)")
          end
        end
      end
    end
  end
end
