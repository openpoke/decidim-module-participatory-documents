# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionForm < Decidim::Form
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations

      attribute :body, String
      attribute :file

      min_length = Decidim::ParticipatoryDocuments.config.min_suggestion_length
      max_length = Decidim::ParticipatoryDocuments.config.max_suggestion_length

      validate :validate_single_field_presence

      validates :body, length: {
        minimum: min_length,
        maximum: max_length,
        too_short: I18n.t("activemodel.errors.models.suggestion.attributes.too_short", min_length: min_length),
        too_long: I18n.t("activemodel.errors.models.suggestion.attributes.too_long", max_length: max_length)
      }, if: -> { body.present? }

      def validate_single_field_presence
        return unless body.blank? && file.blank?

        errors.add(:base, I18n.t("activemodel.errors.models.suggestion.attributes.not_blank"))
      end
    end
  end
end
