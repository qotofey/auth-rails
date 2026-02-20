# frozen_string_literal: true

class PasswordFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # Валидация формата пароля не требуется по ТЗ
    # Только длина 10-64 символа
  end
end
