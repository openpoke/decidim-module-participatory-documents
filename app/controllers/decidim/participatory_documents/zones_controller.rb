# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class ZonesController < Decidim::ParticipatoryDocuments::ApplicationController

      def show
        render json: {}, status: :ok
      end
    end
  end
end
