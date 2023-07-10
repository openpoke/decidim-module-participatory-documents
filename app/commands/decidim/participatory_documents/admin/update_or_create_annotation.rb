# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateOrCreateAnnotation < Decidim::Command
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
            @old_section = annotation.present? ? annotation.section : nil

            transaction do
              create_section! if section.blank?
              create_annotation! if annotation.blank?
              annotation.assign_attributes(**attributes)
              update_annotation! if annotation.changed?
            end

            destroy_old_section!
            document.update_positions!

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
            document: document
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
          @section ||= document.sections.find_by(id: form.section)
        end

        def annotation
          @annotation ||= document.annotations.find_by(id: form.id)
        end
      end
    end
  end
end
