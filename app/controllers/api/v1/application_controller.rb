# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

      # def render_not_found(exception)
      #   render json: { error: exception.message }, status: :not_found
      # end

      private

      def render_unprocessable_entity(exception)
        field_name = exception.param

        binding.irb
        render json: {
          errors: [
            {
              status: "422",
              source: { pointer: "/#{field_name}" },
              title: "",
              detail: exception.message
            }
          ]
        }, status: :unprocessable_entity
      end

      def render_not_found
        render json: {
          jsonapi: { version: "1.1" },
          errors: [
            {
              status: "404",
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
              status: "401",
              title: "Forbidden"
            }
          ]
        }, status: :forbidden
      end
    end
  end
end
