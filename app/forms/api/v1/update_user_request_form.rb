# frozen_string_literal: true

require "action_controller"

module Api
  module V1
    class UpdateUserRequestForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :data, :type, :attributes

      # Валидации для data
      validate :data_presence
      validate :data_must_be_hash

      # Валидации для type (только если data присутствует)
      validate :validate_type, if: :data_present?

      # Валидации для attributes (только если data присутствует)
      validate :validate_attributes, if: :data_present?

      # Валидации для полей внутри attributes (только если data, type, attributes присутствуют и type корректен)
      validate :validate_attributes_fields, if: :data_type_attributes_valid?

      def data_present?
        !data.nil?
      end

      def data_type_attributes_valid?
        data_present? && !type.nil? && !attributes.nil? && errors[:type].empty?
      end

      def initialize(params)
        @data = params[:data] || params["data"]
        @type = params[:type] || params["type"] || @data&.[]("type") || @data&.[](:type)
        @attributes = params[:attributes] || params["attributes"] || @data&.[]("attributes") || @data&.[](:attributes)
      end

      def extracted_attributes
        {
          name: attributes&.[]("name") || attributes&.[](:name),
          middle_name: attributes&.[]("middleName") || attributes&.[](:middle_name),
          last_name: attributes&.[]("lastName") || attributes&.[](:last_name),
          gender: attributes&.[]("gender") || attributes&.[](:gender),
          birth_date: attributes&.[]("birthDate") || attributes&.[](:birth_date)
        }
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

      def validate_attributes_fields
        # Проверяем, что хотя бы одно поле присутствует
        if attributes.blank? || (
          attributes[:name].blank? && attributes["name"].blank? &&
          attributes[:middle_name].blank? && attributes["middle_name"].blank? &&
          attributes[:middleName].blank? && attributes["middleName"].blank? &&
          attributes[:last_name].blank? && attributes["last_name"].blank? &&
          attributes[:lastName].blank? && attributes["lastName"].blank? &&
          attributes[:gender].blank? && attributes["gender"].blank? &&
          attributes[:birth_date].blank? && attributes["birth_date"].blank? &&
          attributes[:birthDate].blank? && attributes["birthDate"].blank?
        )
          errors.add(:attributes, :blank, message: "должен содержать хотя бы одно поле для обновления")
        end
      end
    end
  end
end
