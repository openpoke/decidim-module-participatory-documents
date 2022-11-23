# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :document

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::AnnotationPresenter
      end

      def serialize
        {
          annotationType: annotation_type,
          color: color.map(&:to_i),
          thickness: thickness,
          opacity: opacity,
          scale: scale,
          paths: paths.map(&:to_i),
          pageIndex: page_index,
          rect: rect.map(&:to_i),
          rotation: rotation
        }
      end
    end
  end
end
