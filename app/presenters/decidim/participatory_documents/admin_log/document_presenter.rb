# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module AdminLog
      class DocumentPresenter < Decidim::Log::BasePresenter
        def action_string
          "decidim.admin_log.document.#{action}"
        end
      end
    end
  end
end