# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionForm < Decidim::Form
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations

      attribute :body, String
      attribute :file

      validate :validate_single_field_presence
      validate :validate_body_length

      private

      def validate_body_length
        return if body.blank?

        errors.add(:body, I18n.t("activemodel.errors.models.suggestion.attributes.too_short", min_length:)) if body.length < min_length
        errors.add(:body, I18n.t("activemodel.errors.models.suggestion.attributes.too_long", max_length:)) if body.length > max_length
      end

      def validate_single_field_presence
        return unless body.blank? && file.blank?

        errors.add(:body, I18n.t("activemodel.errors.models.suggestion.attributes.not_blank"))
      end

      def min_length
        current_component.settings.min_suggestion_length || Decidim::ParticipatoryDocuments.config.min_suggestion_length
      end

      def max_length
        current_component.settings.max_suggestion_length || Decidim::ParticipatoryDocuments.config.max_suggestion_length
      end
    end
  end
end
