# frozen_string_literal: true

class UserPassword < ApplicationRecord
  has_secure_password

  belongs_to :user

  def password=(unencrypted_password)
    if unencrypted_password.present?
      self.password_digest = BCrypt::Password.create(
        unencrypted_password,
        cost: Rails.env.production? ? BCrypt::Engine::DEFAULT_COST : ENV.fetch("BCRYPT_COST", 12).to_i
      )
    end
  end
end
