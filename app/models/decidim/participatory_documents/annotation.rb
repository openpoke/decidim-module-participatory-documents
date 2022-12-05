# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      belongs_to :zone, class_name: "Decidim::ParticipatoryDocuments::Zone"

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::AnnotationPresenter
      end

      def serialize
        {
          id: "box-#{id}",
          rect: rect,
          group: "group-#{zone_id}",
          page_number: page_number
        }
      end
    end
  end
end
