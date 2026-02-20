# frozen_string_literal: true

module Api
  module V1
    class UpdateUserForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :user, :name, :middle_name, :last_name, :gender, :birth_date

      validates :gender, inclusion: { in: %w[male female], message: "может быть только male или female" }, allow_blank: true
      validate :validate_name_format
      validate :validate_middle_name_format
      validate :validate_last_name_format
      validate :validate_birth_date

      def initialize(user, params)
        @user = user
        @name = params[:name]
        @middle_name = params[:middle_name]
        @last_name = params[:last_name]
        @gender = params[:gender]
        @birth_date = params[:birth_date]
      end

      def save
        return false unless valid?

        User.transaction do
          user.name = normalize_name(name) if name.present?
          user.middle_name = normalize_name(middle_name) if middle_name.present?
          user.last_name = normalize_name(last_name) if last_name.present?
          user.gender = gender&.downcase if gender.present?
          user.birth_date = birth_date if birth_date.present?
          user.save!
        end
      end

      private

      def normalize_name(value)
        normalized = normalize_name_for_validation(value)
        normalized.split("-").map { |part| part.mb_chars.capitalize.to_s }.join("-")
      end

      def validate_name_format
        return if name.blank?
        normalized = normalize_name_for_validation(name)
        return if normalized.match?(/\A[\p{L}-]+\z/)

        errors.add(:name, :invalid_format, message: "может содержать только буквы и дефис")
      end

      def validate_middle_name_format
        return if middle_name.blank?
        normalized = normalize_name_for_validation(middle_name)
        return if normalized.match?(/\A[\p{L}-]+\z/)

        errors.add(:middle_name, :invalid_format, message: "может содержать только буквы и дефис")
      end

      def validate_last_name_format
        return if last_name.blank?
        normalized = normalize_name_for_validation(last_name)
        return if normalized.match?(/\A[\p{L}-]+\z/)

        errors.add(:last_name, :invalid_format, message: "может содержать только буквы и дефис")
      end

      def normalize_name_for_validation(value)
        # Заменяем все виды дефисов/тире на обычный дефис для валидации
        value.to_s.strip
          .gsub(/[\u002D\u00AD\u058A\u05BE\u1400\u1806\u2010\u2011\u2012\u2013\u2014\u2015\u2212\u2E3A\u2E3B\u301C\u3030\u30A0\uFF0D]+/, "-")
          .gsub(/\s*-\s*/, "-")  # Удаляем пробелы вокруг дефисов
          .gsub(/-+/, "-")  # Заменяем множественные дефисы на один
          .gsub(/^-+|-+$/, "")  # Удаляем дефисы по краям
      end

      def validate_birth_date
        return if birth_date.blank?

        if birth_date.is_a?(String)
          begin
            Date.parse(birth_date)
          rescue ArgumentError
            errors.add(:birth_date, :invalid_format, message: "должна быть в формате YYYY-MM-DD")
          end
        elsif !birth_date.is_a?(Date)
          errors.add(:birth_date, :invalid_format, message: "должна быть датой")
        end
      end
    end
  end
end
