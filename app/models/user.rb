# frozen_string_literal: true

require "paranoia"

class User < ApplicationRecord
  acts_as_paranoid

  has_many :credentials, class_name: "UserCredential", dependent: :destroy
  has_one :password, class_name: "UserPassword", dependent: :destroy

  # Нормализация выполняется в UpdateUserForm
  # normalizes :name, with: ->(name) { name.to_s.strip.titleize }
  # normalizes :middle_name, with: ->(middle_name) { middle_name.to_s.strip.titleize }
  # normalizes :last_name, with: ->(last_name) { last_name.to_s.strip.titleize }

  enum :gender, {
    female: "female",
    male: "male"
  }

  accepts_nested_attributes_for :credentials
  accepts_nested_attributes_for :password

  validates :name, length: { maximum: 64 }# , plain_name: true
  validates :middle_name, length: { maximum: 64 }# , plain_name: true
  validates :last_name, length: { maximum: 64 }# , plain_name: true

  alias_attribute :first_name, :name

  def full_name
    @full_name ||= [ name, middle_name, last_name ].compact.select(&:present?).join(" ")
  end

  def username
    @username ||= self.credentials&.username&.take.login
  end
end
