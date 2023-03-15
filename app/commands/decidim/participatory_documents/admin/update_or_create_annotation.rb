# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateOrCreateAnnotation < Rectify::Command
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

          begin
            @old_section = annotation.section
            transaction do
              annotation.assign_attributes(**attributes)
              update_annotation! if annotation.changed?
            end

            destroy_old_section!

            broadcast(:ok, annotation)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
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

        # Destroys the old section if has no more annotations
        def destroy_old_section!
          return unless @old_section
          return if @old_section.annotations.reload.any?

          Decidim.traceability.perform_action!(
            :delete,
            @old_section,
            form.current_user
          ) do
            @old_section.destroy!
          end
        end

        def attributes
          {
            page_number: form.page_number,
            rect: form.rect,
            section: section
          }
        end

        def section
          @section ||= document.sections.find_by(id: form.section) || Decidim::ParticipatoryDocuments::Section.new(document: document)
        end

        def annotation
          @annotation ||= document.annotations.find_by(id: form.id) || Decidim::ParticipatoryDocuments::Annotation.new
        end
      end
    end
  end
end
