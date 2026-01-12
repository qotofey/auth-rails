# # frozen_string_literal: true

class UserCredential < ApplicationRecord
  belongs_to :user

  # enum kind: {
  #   username: "username",
  #   email: "email",
  #   phone: "phone"
  # }

  validates :kind, presence: true
  validates :login, presence: true, uniqueness: { case_sensitive: false }
end
