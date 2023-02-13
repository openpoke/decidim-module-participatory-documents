# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module AdminLog
      # This class holds the logic to present a `Decidim::ParticipatoryDocuments::SuggestionNote`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    SuggestionNotePresenter.new(action_log, view_helpers).present
      class SuggestionNotePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            body: :string
          }
        end

        def i18n_params
          super.merge({
                        suggestion: suggestion_presenter.present
                      })
        end

        def suggestion_presenter
          Decidim::Log::ResourcePresenter.new(action_log.resource.suggestion, h, title: action_log.resource.suggestion)
        end

        def action_string
          case action
          when "create"
            "decidim.admin_log.suggestion_note.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.suggestion_note"
        end
      end
    end
  end
end
