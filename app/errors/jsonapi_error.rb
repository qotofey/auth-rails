# frozen_string_literal: true

module JsonapiError
  class ErrorObject
    attr_reader :status, :title, :detail, :source, :code, :meta

    def initialize(status:, title: nil, detail: nil, source: nil, code: nil, meta: nil)
      @status = status.to_s
      @title = title
      @detail = detail
      @source = source
      @code = code
      @meta = meta
    end

    def to_hash
      {
        status: status,
        title: title,
        detail: detail,
        source: source,
        code: code,
        meta: meta
      }.compact
    end
  end

  class Builder
    def initialize
      @errors = []
    end

    def add(status:, title: nil, detail: nil, source: nil, code: nil, meta: nil)
      @errors << ErrorObject.new(
        status: status,
        title: title,
        detail: detail,
        source: source,
        code: code,
        meta: meta
      )
      self
    end

    def add_attribute_error(attribute, message, status: 422)
      @errors << ErrorObject.new(
        status: status.to_s,
        title: humanize_error(message),
        detail: message,
        source: { pointer: "/data/attributes/#{attribute}" }
      )
      self
    end

    def add_relationship_error(relationship, message, status: 422)
      @errors << ErrorObject.new(
        status: status.to_s,
        title: humanize_error(message),
        detail: message,
        source: { pointer: "/data/relationships/#{relationship}" }
      )
      self
    end

    def add_active_model_errors(active_model_errors, status: 422)
      active_model_errors.each do |attribute, messages|
        messages.each do |message|
          add_attribute_error(attribute, message, status: status)
        end
      end
      self
    end

    def build
      { errors: @errors.map(&:to_hash) }
    end

    def render_in(controller, status: nil)
      controller.render json: build, status: status || @errors.first&.status || 400
    end

    private

    def humanize_error(message)
      message.to_s.humanize
    end
  end

  class << self
    def build(status:, title: nil, detail: nil, source: nil, code: nil, meta: nil)
      Builder.new.add(
        status: status,
        title: title,
        detail: detail,
        source: source,
        code: code,
        meta: meta
      ).build
    end

    def from_active_model(active_model_errors, status: 422)
      Builder.new.add_active_model_errors(active_model_errors, status: status).build
    end

    def builder
      Builder.new
    end

    def render_not_found(controller, detail: "Resource not found")
      controller.render json: build(
        status: 404,
        title: "Not Found",
        detail: detail
      ), status: :not_found
    end

    def render_unauthorized(controller, detail: "Unauthorized access")
      controller.render json: build(
        status: 401,
        title: "Unauthorized",
        detail: detail
      ), status: :unauthorized
    end

    def render_forbidden(controller, detail: "Access denied")
      controller.render json: build(
        status: 403,
        title: "Forbidden",
        detail: detail
      ), status: :forbidden
    end

    def render_validation_errors(controller, errors, status: :unprocessable_entity)
      controller.render json: from_active_model(errors, status: 422), status: status
    end

    def render_internal_error(controller, detail: "Internal server error")
      controller.render json: build(
        status: 500,
        title: "Internal Server Error",
        detail: detail
      ), status: :internal_server_error
    end
  end
end
