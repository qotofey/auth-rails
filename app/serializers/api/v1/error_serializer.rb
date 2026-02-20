# frozen_string_literal: true

module Api
  module V1
    class ErrorSerializer
      def initialize(errors, status: nil)
        @errors = errors
        @status = status || extract_status(errors)
      end

      def serializable_hash
        if @errors.respond_to?(:messages)
          # ActiveModel::Errors
          JsonapiError.from_active_model(@errors.messages, status: @status)
        elsif @errors.is_a?(Hash)
          # Уже готовый hash с ошибками
          @errors
        else
          # Массив или другой формат
          JsonapiError.builder.add(
            status: @status || 400,
            title: "Error",
            detail: @errors.to_s
          ).build
        end
      end

      def to_json(_options = nil)
        serializable_hash.to_json
      end

      private

      def extract_status(errors)
        if errors.respond_to?(:first) && errors.first.is_a?(Hash)
          errors.first["status"] || errors.first[:status]
        else
          400
        end
      end
    end

    class JsonapiError
      def self.builder
        new
      end

      def self.from_active_model(messages, status: 422)
        errors = []
        messages.each do |attribute, messages_list|
          Array(messages_list).each do |message|
            errors << {
              source: { pointer: "/data/attributes/#{attribute}" },
              title: error_title(message),
              detail: message,
              code: error_code(message),
              status: status.to_s
            }
          end
        end
        { errors: errors }
      end

      def self.error_title(message)
        case
        when message.include?("не может быть пустым")
          "Обязательный атрибут отсутствует"
        when message.include?("недостаточной длины")
          "Недостаточная длина"
        when message.include?("слишком большой длины")
          "Превышена максимальная длина"
        when message.include?("может содержать буквы")
          "Неверный формат"
        when message.include?("уже существует")
          "Значение уже существует"
        when message.include?("должен содержать буквы")
          "Неверный формат"
        else
          "Ошибка валидации"
        end
      end

      def self.error_code(message)
        case
        when message.include?("не может быть пустым")
          "required_attribute_missing"
        when message.include?("недостаточной длины")
          "value_too_short"
        when message.include?("слишком большой длины")
          "value_too_long"
        when message.include?("может содержать буквы")
          "invalid_format"
        when message.include?("уже существует")
          "value_taken"
        when message.include?("должен содержать буквы")
          "invalid_format"
        else
          "validation_error"
        end
      end

      def initialize
        @errors = []
      end

      def add(error_hash)
        @errors << error_hash
        self
      end

      def build
        { errors: @errors }
      end
    end
  end
end
