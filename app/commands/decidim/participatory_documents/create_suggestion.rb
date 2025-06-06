# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class CreateSuggestion < Decidim::Command
      include ::Decidim::AttachmentAttributesMethods
      include ::Decidim::AttachmentMethods
      def initialize(form, suggestable)
        @form = form
        @suggestable = suggestable
      end

      def call
        return broadcast(:invalid) if form.invalid?

        begin
          transaction do
            create_suggestion
          end
          broadcast(:ok, suggestion)
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.info e.message
          broadcast(:invalid, e.message)
        end
      end

      private

      attr_reader :form, :suggestion, :suggestable

      def create_suggestion
        sanitized_body = Decidim::ContentProcessor.sanitize(form.body)
        @suggestion = Decidim.traceability.create!(
          Decidim::ParticipatoryDocuments::Suggestion,
          form.current_user,
          body: { I18n.locale => sanitized_body },
          suggestable:,
          author: form.current_user
        )

        @suggestion.file.attach(form.file) if form.file.present?
        @suggestion.save!
      end
    end
  end
end
