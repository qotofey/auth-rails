# frozen_string_literal: true

class UserCredential < ApplicationRecord
  has_many :sessions, class_name: "UserSession", dependent: :destroy
  belongs_to :user

  normalizes :login, with: ->(login) { login.strip.downcase }

  enum :kind, {
    username: "username",
    email: "email",
    phone: "phone"
  }

  validates :kind, presence: true
  validates :login, presence: true, uniqueness: { case_sensitive: false }

  alias_attribute :namename, :login
end
