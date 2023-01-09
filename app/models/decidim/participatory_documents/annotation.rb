# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      belongs_to :section, class_name: "Decidim::ParticipatoryDocuments::Section"

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::AnnotationPresenter
      end

      def serialize
        {
          id: uid,
          rect: rect,
          group: section.uid,
          page_number: page_number
        }
      end
    end
  end
end
