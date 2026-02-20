# frozen_string_literal: true

module Api
  module V1
    module Authentication
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_user!
      end

      private

      def authenticate_user!
        token = extract_token

        if token.blank?
          render_unauthenticated(I18n.t("activemodel.errors.messages.unauthenticated"))
          return
        end

        payload = JwtDecoder.call(token)

        if payload.blank?
          render_unauthenticated(I18n.t("activemodel.errors.messages.invalid_refresh_token"))
          return
        end

        @current_user = User.find_by(id: payload["sub"])

        if @current_user.nil?
          render_unauthenticated(I18n.t("activemodel.errors.messages.user_not_found"))
          return
        end

        if @current_user.deleted_at.present?
          render_gone
          return
        end
      end

      def current_user
        @current_user
      end

      def extract_token
        header = request.headers["Authorization"]
        return nil if header.blank?

        parts = header.split
        return nil if parts.size != 2 || parts.first != "Bearer"

        parts.second
      end

      def render_unauthenticated(detail = I18n.t("activemodel.errors.messages.unauthenticated"))
        render json: {
          errors: [
            {
              source: { header: "Authentication" },
              title: I18n.t("activemodel.errors.messages.unauthenticated"),
              detail: detail,
              status: "401"
            }
          ]
        }, status: :unauthorized
      end

      def render_forbidden_custom(detail = I18n.t("activemodel.errors.messages.unauthorized"))
        render json: {
          errors: [
            {
              title: I18n.t("activemodel.errors.messages.unauthorized"),
              detail: detail,
              status: "403"
            }
          ]
        }, status: :forbidden
      end

      def render_gone
        render json: {
          errors: [
            {
              title: I18n.t("activemodel.errors.messages.gone"),
              detail: I18n.t("activemodel.errors.messages.gone"),
              status: "410"
            }
          ]
        }, status: :gone
      end
    end
  end
end
