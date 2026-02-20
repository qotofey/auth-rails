# frozen_string_literal: true

class UsernameUniqueValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # Проверяем наличие в UserCredential с kind = 'username'
    if UserCredential.exists?(login: value.downcase, kind: :username)
      record.errors.add(
        attribute,
        :taken,
        message: "#{attribute} уже существует"
      )
    end
  end
end
