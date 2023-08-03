# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateDocument < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              create_document
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
            component: form.current_component,
            author: form.current_user,
            title: form.title,
            description: form.description,
            box_color: form.box_color,
            box_opacity: form.box_opacity
          }.merge(attachment_attributes(:file))
        end

        def create_document
          @document = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Document,
            form.current_user,
            **attributes
          )
        end
      end
    end
  end
end
