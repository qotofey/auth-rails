# frozen_string_literal: true

module Api
  module V1
    class ErrorSerializer
      def initialize(active_model_errors)
        @errors = Array(active_model_errors)
      end

      def serializable_hash
        {
          errors: []
        }
      end

      private

      def serialized_errors
      end

      def build_errors_item
        {
          user: [ "must exist" ],
          kind: [ "can't be blank" ],
          login: [ "can't be blank" ]
        }.map do |attribute, messages|
            messages.map do |message_text|
              {
                status: 422,
                source: {
                  pointer: "/data/attributes/#{attribute.to_s.camelize(:lower)}"
                },
                detail: "#{attribute} #{message_text}"
              }
            end
          end
      end
    end
  end
end
