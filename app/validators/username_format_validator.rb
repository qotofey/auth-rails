# frozen_string_literal: true

class UsernameFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # Разрешены только буквы английского алфавита и цифры
    unless value.match?(/\A[a-zA-Z0-9]+\z/)
      record.errors.add(
        attribute,
        :invalid_format,
        message: "#{attribute} может содержать только буквы и цифры английского алфавита"
      )
    end
  end
end
