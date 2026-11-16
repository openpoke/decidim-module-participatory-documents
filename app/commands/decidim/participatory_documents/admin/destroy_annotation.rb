# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DestroyAnnotation < Decidim::Command
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

          transaction do
            section = annotation.section
            destroy_annotation!
            destroy_section_without_annotations!(section)
          end
          document.update_positions!

          broadcast(:ok)
        rescue ActiveRecord::RecordNotDestroyed
          broadcast(:invalid)
        end

        private

        attr_reader :form, :document

        def destroy_annotation!
          Decidim.traceability.perform_action!(:delete, annotation, form.current_user) { annotation.destroy! }
        end

        def annotation
          @annotation ||= document.annotations.find(form.id)
        end
      end
    end
  end
end
