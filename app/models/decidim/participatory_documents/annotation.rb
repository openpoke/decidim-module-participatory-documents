# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      belongs_to :zone, class_name: "Decidim::ParticipatoryDocuments::Zone", counter_cache: true

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::AnnotationPresenter
      end

      def serialize
        {
          id: uid,
          rect: rect,
          group: zone.uid,
          page_number: page_number
        }
      end
    end
  end
end
