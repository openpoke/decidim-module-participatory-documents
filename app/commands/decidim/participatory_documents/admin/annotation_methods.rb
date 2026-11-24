# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module AnnotationMethods
        private

        def destroy_section_without_annotations!(section)
          return if section.blank? || section.annotations.reload.any?

          Decidim.traceability.perform_action!(:delete, section, form.current_user) { section.destroy! }
        end
      end
    end
  end
end
