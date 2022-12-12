# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class VisibleAnnotations < Rectify::Query
      def self.for(document, user)
        new(document, user).query
      end

      def initialize(document, user)
        @document = document
        @user = user
      end

      def query
        @document.annotations.where(zone_id: @document.zones.published)
      end
    end
  end
end
