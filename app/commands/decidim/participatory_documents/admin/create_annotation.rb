# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateAnnotation < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              create_annotation
            end
            broadcast(:ok, annotation)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :annotation, :document

        def create_annotation
          @annotation = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Annotation,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            page_number: form.page_number,
            rect: form.rect
          }.merge(section: section)
        end

        def section
          @section ||= Decidim::ParticipatoryDocuments::Section.where(document: document, id: form.section).first_or_create
        end
      end
    end
  end
end
