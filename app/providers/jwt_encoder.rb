# frozen_string_literal: true

class JwtEncoder
  def initialize(user_id)
    @user_id = user_id
  end

  def call
    build_jwt_or_nil
  end

  private

  def build_jwt_or_nil
    JWT.encode(build_claims, secret, "HS256", build_header)
  rescue
    nil
  end

  def secret
    ENV.fetch("JWT_SECRET_KEY", Rails.application.credentials.secret_key_base)
  end

  def build_header
    {
      typ: "JWT",
      alg: "HS256"
    }
  end

  def build_claims
    {
      sub: @user_id,
      exp: expires_at,
      iat: issued_at
    }
  end

  def issued_at
    @inited_at ||= Time.current.to_i
  end

  def expires_at
    issued_at + access_token_expiration.minutes.to_i
  end

  def access_token_expiration
    ENV.fetch("JWT_ACCESS_TOKEN_EXPIRATION", 15).to_i
  end
end
