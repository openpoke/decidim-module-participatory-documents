# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      belongs_to :section, class_name: "Decidim::ParticipatoryDocuments::Section"
      has_many :suggestions, class_name: "Decidim::ParticipatoryDocuments::Suggestion", dependent: :restrict_with_error, as: :suggestable

      delegate :document, to: :section
      delegate :organization, :participatory_space, :component, to: :document, allow_nil: true

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::AnnotationPresenter
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
