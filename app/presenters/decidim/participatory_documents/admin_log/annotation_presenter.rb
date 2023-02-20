# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module AdminLog
      class AnnotationPresenter < Decidim::Log::BasePresenter
        def action_string
          "decidim.admin_log.annotation.#{action}"
        end

        private

        def i18n_params
          super.merge({ document_name: document_presenter })
        end

        def document_presenter
          return "" if action_log.resource.blank?

          Decidim::Log::ResourcePresenter.new(action_log.resource.section.document, h, action_log.resource.section.document).present
        end
      end
    end
  end
end
