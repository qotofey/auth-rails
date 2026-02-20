# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      include ActionController::Cookies

      def create
        form = AuthenticationForm.new(extract_params)

        if form.valid?
          authenticate_user(form)
        else
          render_validation_errors(form.errors)
        end
      end

      def update
        refresh_token = cookies[:refresh_token]

        if refresh_token.blank?
          render_missing_refresh_token
          return
        end

        session_record = UserSession.find_by(token: refresh_token)

        if session_record.nil? || !session_record.active?
          render_invalid_refresh_token
          return
        end

        # Проверяем срок действия refresh токена (21 день)
        if session_record.created_at < refresh_token_expiration.days.ago
          session_record.disable!
          render_invalid_refresh_token
          return
        end

        # Генерируем новые токены
        user_credential = session_record.user_credential
        new_refresh_token = generate_refresh_token

        # Создаем новую сессию
        user_credential.sessions.create!(token: new_refresh_token)
        # Отключаем старый refresh токен
        session_record.disable!

        set_refresh_token_cookie(new_refresh_token)

        render json: {
          meta: {
            accessToken: JwtEncoder.new(user_credential.user_id).call
          }
        }, status: :created
      end

      def destroy
        refresh_token = cookies[:refresh_token]

        if refresh_token.present?
          session_record = UserSession.find_by(token: refresh_token)
          session_record&.disable!
          cookies.delete(:refresh_token)
        end

        head :no_content
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

      def authenticate_user(form)
        credential = UserCredential.find_by(login: form.username, kind: :username)

        if credential&.user&.password&.authenticate(form.password)
          # Генерируем refresh токен
          refresh_token = generate_refresh_token

          # Создаем сессию
          credential.sessions.create!(token: refresh_token)

          # Устанавливаем cookie
          set_refresh_token_cookie(refresh_token)

          render json: {
            meta: {
              accessToken: JwtEncoder.new(credential.user_id).call
            }
          }, status: :created
        else
          render json: {
            errors: [
              {
                source: { pointer: "/data/attributes" },
                title: I18n.t("activemodel.errors.messages.invalid_credentials"),
                detail: I18n.t("activemodel.errors.messages.invalid_credentials"),
                status: "422"
              }
            ]
          }, status: :unprocessable_entity
        end
      end

      def generate_refresh_token
        SecureRandom.alphanumeric(64)
      end

      def set_refresh_token_cookie(token)
        cookies[:refresh_token] = {
          value: token,
          expires: refresh_token_expiration.days.from_now,
          path: "/",
          domain: :all,
          httponly: true,
          same_site: :lax,
          secure: Rails.env.production?
        }
      end

      def refresh_token_expiration
        ENV.fetch("JWT_REFRESH_TOKEN_EXPIRATION", 21).to_i
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
        else
                    "/data/attributes/#{error.attribute}"
        end

        {
          source: { pointer: pointer },
          title: error_type_to_title(error.type),
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
          I18n.t("activemodel.errors.messages.validation_error")
        end
      end

      def render_missing_refresh_token
        render json: {
          errors: [
            {
              source: { header: "Authentication" },
              title: I18n.t("activemodel.errors.messages.unauthenticated"),
              detail: I18n.t("activemodel.errors.messages.unauthenticated"),
              status: "401"
            }
          ]
        }, status: :unauthorized
      end

      def render_invalid_refresh_token
        render json: {
          errors: [
            {
              source: { header: "Authentication" },
              title: I18n.t("activemodel.errors.messages.unauthenticated"),
              detail: I18n.t("activemodel.errors.messages.invalid_refresh_token"),
              status: "401"
            }
          ]
        }, status: :unauthorized
      end
    end
  end
end
