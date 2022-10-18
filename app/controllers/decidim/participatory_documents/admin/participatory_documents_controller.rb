# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ParticipatoryDocumentsController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        def index; end
      end
    end
  end
end
