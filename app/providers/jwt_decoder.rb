# frozen_string_literal: true

class JwtDecoder
  def self.call(token)
    new(token).call
  end

  def initialize(token)
    @token = token
  end

  def call
    decode_jwt
  rescue JWT::ExpiredSignature
    nil
  rescue JWT::DecodeError
    nil
  end

  private

  attr_reader :token

  def decode_jwt
    payload, _header = JWT.decode(token, secret, true, { algorithm: "HS256" })
    payload
  end

  def secret
    ENV.fetch("JWT_SECRET_KEY", Rails.application.credentials.secret_key_base)
  end
end
