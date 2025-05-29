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
          return unless allowed_to?(:create, :suggestion_note, suggestion:) || allowed_to?(:update, :suggestion_answer, suggestion:)

          icon_link_to("question-answer-line",
                       document_suggestion_path(document, suggestion),
                       t(:answer, scope: "decidim.participatory_documents.admin.suggestions.index.actions"),
                       class: "icon--small action-icon--show-suggestion")
        end

        def bulk_valuators_select(participatory_space, prompt)
          options_for_select = find_valuators_for_select(participatory_space)
          select(:valuator_role, :id, options_for_select, prompt:)
        end

        def suggestion_content(suggestion)
          {
            text: suggestion_body(suggestion),
            file_link: suggestion.file.attached? && file_link(suggestion)
          }
        end

        private

        def file_link(suggestion)
          icon_link_to("file-download-line",
                       Rails.application.routes.url_helpers.rails_blob_url(suggestion.file.blob, only_path: true, target: "_blank", rel: "noopener"),
                       t("decidim.participatory_documents.admin.suggestions.index.actions.download", filename: suggestion.file.filename.to_s),
                       class: "icon--small ml-xs",
                       target: "_blank",
                       data: { externalLink: false })
        end

        def content_with_class(content, css_class)
          content_tag(:span, content, class: css_class)
        end

        def suggestion_body(suggestion)
          suggestion.body[I18n.locale.to_s].presence || content_with_class(t("decidim.participatory_documents.admin.suggestions.index.no_text"), "muted")
        end
      end
    end
  end
end
