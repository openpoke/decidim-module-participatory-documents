# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper Decidim::ParticipatoryDocuments::DocumentsHelper
      helper_method :document

      private

      def document
        @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
      end
    end
  end
end
