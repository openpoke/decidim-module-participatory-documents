# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateDocument < Rectify::Command
        include ::Decidim::AttachmentAttributesMethods

        def initialize(form, document)
          @form = form
          @document = document
          @attached_to = document
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              update_document
            end
            broadcast(:ok, document)
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
      end
    end
  end
end
