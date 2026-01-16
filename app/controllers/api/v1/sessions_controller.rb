# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      include ActionController::Cookies
      # before_action :set_session, only: %i[show update destroy]

      def index
        render json: {}, status: :ok
      end

      def show
        render json: {}, status: :ok
      end

      def create
        # binding.irb

        from = AuthenticationForm.new(authentication_params)
        refresh_token = SecureRandom.base58(64)

        credential = UserCredential.find_by(login: from.username)
        secret = UserPassword.find_by(user_id: credential.user_id)

        if secret.authenticate(from.password)
          credential.sessions.create(token: refresh_token)

          cookies["refresh_token"] = {
            value: refresh_token,
            expires: 7.days.from_now,
            path: "/",
            domain: :all,
            httponly: true,
            same_site: :lax,
            secure: Rails.env.production?
          }

          render json: {
            meta: {
              accessToken: JwtEncoder.new(credential.user_id).call
            }
          }, status: :created
        else
          render json: {
            errors: [
              {
                status: 422,
                title: "Неверный логин или пароль",
                detail: "Неверный логин или пароль"
              }
            ]
          }, status: :unprocessable_entity
        end
      end

      def update
        # binding.irb
        refresh_token = cookies["refresh_token"]
        render json: { status: :updated }, status: :created
      end

      def delete
      end

      private

      def set_session
        # @session = nil
      end

      def authentication_params
        params
          .expect(
            data: [ attributes: %i[username password] ]
          )
      end
    end
  end
end
