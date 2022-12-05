# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module AdminLog
      class ZonePresenter < Decidim::Log::BasePresenter
        def action_string
          "decidim.admin_log.zone.#{action}"
        end

        private

        def i18n_params
          super.merge({
                        document_name: document_presenter.present
                      })
        end

        def document_presenter
          Decidim::Log::ResourcePresenter.new(action_log.resource.document, h, action_log.resource.document)
        end
      end
    end
  end
end
