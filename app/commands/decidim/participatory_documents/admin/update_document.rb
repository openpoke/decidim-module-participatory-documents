# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateDocument < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              destroy_sections!
              update_document
            end
            broadcast(:ok, document)
          rescue ActiveRecord::RecordNotDestroyed => e
            # if sections contains annotations, can be deleted
            # if sections contains suggestions, cannot be deleted
            broadcast(:error, e.message)
          rescue ActiveRecord::RecordInvalid
            form.errors.add(:file, document.errors[:file]) if document.errors.include? :file
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :document

        def attributes
          {
            title: form.title,
            description: form.description,
            box_color: form.box_color,
            box_opacity: form.box_opacity
          }.merge(attachment_attributes(:file))
        end

        def update_document
          Decidim.traceability.update!(
            document,
            form.current_user,
            **attributes
          )
        end

        def file_changed?
          form.file.present? && form.file != document.file.blob
        end

        def destroy_sections!
          return unless file_changed?

          raise ActiveRecord::RecordNotDestroyed, I18n.t("activemodel.errors.models.document.has_suggestions") if document.has_suggestions?

          return unless document.sections.any?

          document.annotations.each do |annotation|
            Decidim.traceability.perform_action!(
              "delete",
              annotation,
              form.current_user
            ) do
              annotation.destroy!
            end
          end

          document.sections.each do |section|
            Decidim.traceability.perform_action!(
              "delete",
              section,
              form.current_user
            ) do
              section.destroy!
            end
          end
        end
      end
    end
  end
end
