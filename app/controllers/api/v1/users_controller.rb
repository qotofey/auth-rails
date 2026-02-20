# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      include Authentication

      skip_before_action :authenticate_user!, only: [:create]

      def show
        render json: UserSerializer.new(current_user).serializable_hash, status: :ok
      end

      def create
        form = RegistrationForm.new(extract_params)

        if form.valid?
          result = create_user(form)
          if result.is_a?(User) && result.persisted?
            render json: UserSerializer.new(result).serializable_hash, status: :created
          else
            render_validation_errors(result.errors)
          end
        else
          render_validation_errors(form.errors)
        end
      end

      def update
        request_form = UpdateUserRequestForm.new(params)

        if request_form.valid?
          form = UpdateUserForm.new(current_user, request_form.extracted_attributes)
          if form.valid?
            if form.save
              render json: UserSerializer.new(current_user).serializable_hash, status: :ok
            else
              render_validation_errors(current_user.errors)
            end
          else
            render_validation_errors(form.errors)
          end
        else
          render_validation_errors(request_form.errors)
        end
      end

      private

      def extract_params
        params_data = params["data"]
        attributes = params_data&.[]("attributes")
        {
          data: params_data,
          type: params_data&.[]("type"),
          attributes: attributes,
          username: attributes&.[]("username"),
          password: attributes&.[]("password")
        }
      end

      def extract_update_params
        params_data = params["data"] || {}
        attributes = params_data["attributes"] || {}
        {
          name: attributes["name"],
          middle_name: attributes["middleName"],
          last_name: attributes["lastName"],
          gender: attributes["gender"],
          birth_date: attributes["birthDate"]
        }
      end

      def create_user(form)
        User.transaction do
          user = User.new
          credential = user.credentials.build(
            login: form.username,
            kind: :username
          )
          password_record = user.build_password(
            password: form.password
          )
          user.save!
          user
        end
      rescue ActiveRecord::RecordInvalid => e
        e.record
      end

      def render_validation_errors(errors)
        error_list = errors.map { |error| build_error_object(error) }
        render json: { errors: error_list }, status: :unprocessable_entity
      end

      def build_error_object(error)
        pointer = case error.attribute.to_s
                  when "username"
                    "/data/attributes/username"
                  when "password"
                    "/data/attributes/password"
                  when "type"
                    "/data/type"
                  when "data"
                    "/data"
                  when "attributes"
                    "/data/attributes"
                  when "name"
                    "/data/attributes/name"
                  when "middle_name"
                    "/data/attributes/middleName"
                  when "last_name"
                    "/data/attributes/lastName"
                  when "gender"
                    "/data/attributes/gender"
                  when "birth_date"
                    "/data/attributes/birthDate"
                  when "login"
                    "/data/attributes/username"
                  when "credentials.login"
                    "/data/attributes/username"
                  else
                    "/data/attributes/#{error.attribute}"
                  end

        title = error_type_to_title(error.type)

        {
          source: { pointer: pointer },
          title: title || "Ошибка валидации",
          detail: error.message,
          status: "422"
        }
      end

      def error_type_to_title(error_type)
        case error_type.to_sym
        when :blank, :required_attribute_missing
          I18n.t("activemodel.errors.messages.required_attribute_missing")
        when :too_long
          I18n.t("activemodel.errors.messages.too_long")
        when :too_short
          I18n.t("activemodel.errors.messages.too_short")
        when :invalid_format
          I18n.t("activemodel.errors.messages.invalid_format")
        when :taken
          I18n.t("activemodel.errors.messages.value_taken")
        when :inclusion
          I18n.t("activemodel.errors.messages.inclusion")
        else
          # Для кастомных сообщений используем error.message напрямую
          nil
        end
      end
    end
  end
end
