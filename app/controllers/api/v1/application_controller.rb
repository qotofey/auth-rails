# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
      rescue_from ActionController::UnknownHttpMethod, with: :render_method_not_allowed
      rescue_from ActionController::BadRequest, with: :render_bad_request
      rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_bad_request

      private

      def render_bad_request(exception = nil)
        render json: {
          errors: [
            {
              source: { header: "Content-Type" },
              title: "Неверный формат запроса",
              detail: "Ошибка в структуре тела запроса.",
              status: "400"
            }
          ]
        }, status: :bad_request
      end

      def render_unprocessable_entity(exception)
        field_name = exception.param

        render json: {
          errors: [
            {
              status: "422",
              source: { pointer: "/data/attributes/#{field_name}" },
              title: I18n.t("activemodel.errors.messages.required_attribute_missing"),
              detail: exception.message
            }
          ]
        }, status: :unprocessable_entity
      end

      def render_not_found
        render json: {
          errors: [
            {
              title: I18n.t("activemodel.errors.messages.not_found"),
              detail: I18n.t("activemodel.errors.messages.not_found"),
              status: "404"
            }
          ]
        }, status: :not_found
      end

      def render_method_not_allowed
        render json: {
          errors: [
            {
              title: I18n.t("activemodel.errors.messages.method_not_allowed"),
              detail: I18n.t("activemodel.errors.messages.method_not_allowed"),
              status: "405"
            }
          ]
        }, status: :method_not_allowed
      end

      def render_forbidden
        render json: {
          errors: [
            {
              title: I18n.t("activemodel.errors.messages.unauthorized"),
              detail: I18n.t("activemodel.errors.messages.unauthorized"),
              status: "403"
            }
          ]
        }, status: :forbidden
      end

      def render_server_error(detail = I18n.t("activemodel.errors.messages.server_error"))
        render json: {
          errors: [
            {
              title: I18n.t("activemodel.errors.messages.server_error"),
              detail: detail,
              status: "500"
            }
          ]
        }, status: :internal_server_error
      end
    end
  end
end
