# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found

      # def render_not_found(exception)
      #   render json: { error: exception.message }, status: :not_found
      # end

      private

      def render_not_found
        render json: {
          jsonapi: { version: "1.1" },
          errors: [
            {
              status: 404,
              title: "Not Found",
              detail: "Page not found"
            }
          ]
        }, status: :not_found
      end

      def render_forbidden
        render json: {
          jsonapi: { version: "1.1" },
          errors: [
            {
              status: 401,
              title: "Forbidden"
            }
          ]
        }, status: :forbidden
      end
    end
  end
end
