# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module AdminLog
      class AnnotationPresenter < Decidim::Log::BasePresenter
        def action_string
          "decidim.admin_log.annotation.#{action}"
        end
      end
    end
  end
end
