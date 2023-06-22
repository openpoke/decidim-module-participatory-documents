# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Section < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::Publicable
      belongs_to :document, class_name: "Decidim::ParticipatoryDocuments::Document"
      has_many :annotations, class_name: "Decidim::ParticipatoryDocuments::Annotation", dependent: :restrict_with_error
      has_many :suggestions, class_name: "Decidim::ParticipatoryDocuments::Suggestion", dependent: :restrict_with_error, as: :suggestable

      delegate :organization, :participatory_space, :component, to: :document, allow_nil: true

      translatable_fields :title
      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::SectionPresenter
      end

      def title
        return artificial_title if attributes["title"].nil?

        artificial_title.merge(super.reject { |_key, value| value.blank? })
      end

      private

      def artificial_title
        artificial = {}
        i18n_scope = "decidim.participatory_documents.models.section.fields"
        default_translation = I18n.with_locale("en") { I18n.t("artificial_tile", scope: i18n_scope, position: position) }

        Decidim.available_locales.map(&:to_s).each do |locale|
          artificial[locale] = I18n.with_locale(locale) { I18n.t("artificial_tile", scope: i18n_scope, position: position, default: default_translation) }
        end
        artificial
      end
    end
  end
end
