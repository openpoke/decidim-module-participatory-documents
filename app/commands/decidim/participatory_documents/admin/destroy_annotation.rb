# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DestroyAnnotation < Decidim::Command
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
            @old_section = annotation.section
            transaction do
              destroy_annotation!
            end

            destroy_old_section!
            document.update_positions!

            broadcast(:ok)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :document

        def destroy_annotation!
          Decidim.traceability.perform_action!(
            :delete,
            annotation,
            form.current_user
          ) do
            annotation.destroy!
          end
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

        def annotation
          @annotation ||= document.annotations.find(form.id)
        end
      end
    end
  end
end
