# frozen_string_literal: true

class UserSession < ApplicationRecord
  belongs_to :user_credential

  validates :token, presence: true, uniqueness: true
  validates :token, length: { maximum: 128 }

  scope :active, -> { where(disabled_at: nil) }

  def active?
    disabled_at.nil?
  end

  def disable!
    update!(disabled_at: Time.current)
  end
end
