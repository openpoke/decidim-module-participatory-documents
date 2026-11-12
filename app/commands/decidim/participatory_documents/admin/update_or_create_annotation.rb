# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateOrCreateAnnotation < Decidim::Command
        include AnnotationMethods

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) if document.nil?

          transaction do
            old_section = annotation&.section
            create_section! if section.blank?
            create_annotation! if annotation.blank?
            annotation.assign_attributes(**attributes)
            update_annotation! if annotation.changed?
            destroy_section_without_annotations!(old_section)
          end
          document.update_positions!

          broadcast(:ok, annotation)
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
          broadcast(:invalid)
        end

        private

        attr_reader :form, :document

        def update_annotation!
          @annotation = Decidim.traceability.update!(
            annotation,
            form.current_user,
            **attributes
          )
        end

        def create_annotation!
          @annotation = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Annotation,
            form.current_user,
            **attributes
          )
        end

        def create_section!
          @section = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Section,
            form.current_user,
            document:
          )
        end

        def attributes
          {
            page_number: form.page_number,
            rect: form.rect,
            section:
          }
        end

        def section
          @section ||= document.sections.find_by(id: form.section)
        end

        def annotation
          @annotation ||= document.annotations.find_by(id: form.id)
        end
      end
    end
  end
end
