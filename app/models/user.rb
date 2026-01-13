# frozen_string_literal: true

class User < ApplicationRecord
  has_many :credentials, class_name: "UserCredential", dependent: :destroy
  has_one :password, class_name: "UserPassword", dependent: :destroy

  normalizes :name, with: ->(name) { name.strip.delete("\s").titleize.to_s }
  normalizes :middle_name, with: ->(middle_name) { middle_name.strip.delete("\s").titleize.to_s }
  normalizes :last_name, with: ->(last_name) { last_name.strip.delete("\s").titleize.to_s }

  enum :gender, {
    female: "female",
    male: "male"
  }

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
