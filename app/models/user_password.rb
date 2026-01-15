# frozen_string_literal: true

class UserPassword < ApplicationRecord
  has_secure_password

  belongs_to :user

  validates :password, length: { in: 10..128 }
end
