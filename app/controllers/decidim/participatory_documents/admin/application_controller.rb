# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper Decidim::ApplicationHelper
        helper Decidim::ParticipatoryDocuments::Admin::DocumentsHelper
        helper_method :document

        protected

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
        end
      end
    end
  end
end
