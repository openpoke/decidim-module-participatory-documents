# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class ZonesController < Decidim::ParticipatoryDocuments::ApplicationController

      helper_method :zone
      layout false , only: [:show]

      def show
      end

      private
      def zone
        @zone ||= document.zones.find_by!(uid: params[:id])
      end

      def document
        @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
      end

    end
  end
end
