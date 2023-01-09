# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class ZonesController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable

      helper_method :zone, :suggestions
      layout false , only: [:show]

      def show
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params({})
      end

      private
      def zone
        @zone ||= document.zones.find_by!(uid: params[:id])
      end


      def suggestions
        zone.suggestions
      end
    end
  end
end
