# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module SuggestionHelper
        def humanize_suggestion_state(state)
          I18n.t(state, scope: "decidim.participatory_documents.suggestions.answers", default: :not_answered)
        end

        def icon_with_link_to_suggestion(document, suggestion)
          return unless allowed_to?(:create, :suggestion_note, suggestion: suggestion) || allowed_to?(:update, :suggestion_answer, suggestion: suggestion)

          icon_link_to("comment-square",
                       document_suggestion_path(document, suggestion),
                       t(:answer, scope: "decidim.participatory_documents.admin.suggestions.index.actions"),
                       class: "icon--small action-icon--show-suggestion")
        end

        def bulk_valuators_select(participatory_space, prompt)
          options_for_select = find_valuators_for_select(participatory_space)
          select(:valuator_role, :id, options_for_select, prompt: prompt)
        end
      end
    end
  end
end
