# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class CreateSuggestion < Decidim::Command
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
          { body: { I18n.locale => sanitized_body },
            suggestable:,
            author: form.current_user },
          visibility: "public-only"
        )

        create_suggestion_attachment if form.file.present?
      end

      def create_suggestion_attachment
        file = form.file
        file_blob = ActiveStorage::Blob.create_after_upload!(
          io: file.open,
          filename: file.original_filename,
          content_type: file.content_type
        )

        attachment = Decidim::Attachment.create!(
          file: file_blob,
          attached_to: suggestion,
          content_type: file.content_type,
          title: { I18n.locale => file.original_filename }
        )

        suggestion.file.attach(attachment.file.blob)

        suggestion.save!
      end
    end
  end
end
