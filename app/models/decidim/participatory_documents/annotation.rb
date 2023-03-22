# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      belongs_to :section, class_name: "Decidim::ParticipatoryDocuments::Section"
      delegate :document, to: :section

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::AnnotationPresenter
      end

      # to have a consecutive number of the boxes
      # Suggestion: try to order by rect coordinates so number go according the UI in the document
      def position
        @position ||= document.annotations.where("decidim_participatory_documents_annotations.id < ?", id).count + 1
      end

      def serialize
        @serialize ||= {
          id: id,
          position: position,
          rect: rect,
          section: section.id,
          section_number: section.position,
          page_number: page_number
        }
      end
    end
  end
end
