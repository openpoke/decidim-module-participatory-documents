# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionForm < Decidim::Form
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations

      MIN_BODY_LENGTH = 15
      MAX_BODY_LENGTH = 150

      attribute :body, String
      attribute :file
      attribute :delete_file, Boolean

      validate :validate_single_field_presence
      validate :validate_body_length

      private

      def validate_single_field_presence
        if body.blank? && file.blank?
          errors.add(:base, I18n.t("activemodel.errors.models.suggestion.attributes.not_blank"))
        elsif body.present? && file.present?
          errors.add(:base, I18n.t("activemodel.errors.models.suggestion.attributes.not_both"))
        end
      end

      def validate_body_length
        return if body.blank?

        if body.length < MIN_BODY_LENGTH
          errors.add(:base, I18n.t("activemodel.errors.models.suggestion.attributes.too_short", min_length: MIN_BODY_LENGTH))
        elsif body.length > MAX_BODY_LENGTH
          errors.add(:base, I18n.t("activemodel.errors.models.suggestion.attributes.too_long", max_length: MAX_BODY_LENGTH))
        end
      end
    end
  end
end
