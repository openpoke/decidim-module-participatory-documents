# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module SuggestionHelper
        include ActionView::Helpers::TextHelper
        include Decidim::Admin::IconLinkHelper

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

        def suggestion_content(suggestion)
          body = suggestion.body[I18n.locale.to_s]
          content = body.presence || t("decidim.participatory_documents.admin.suggestions.index.no_text")
          file_link = suggestion.file.attached? ? file_link(suggestion) : nil

          { text: content, file_link: file_link }
        end

        private

        def file_link(suggestion)
          icon_link_to("data-transfer-download",
                       Rails.application.routes.url_helpers.rails_blob_url(suggestion.file.blob, only_path: true, target: "_blank", rel: "noopener"),
                       t("decidim.participatory_documents.admin.suggestions.index.actions.download", filename: suggestion.file.filename.to_s),
                       class: "icon--small ml-xs")
        end
      end
    end
  end
end
