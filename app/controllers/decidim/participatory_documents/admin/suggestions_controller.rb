# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionsController < Admin::ApplicationController
        include Decidim::Admin::Filterable
        include Decidim::Admin::Paginable
        helper Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
        helper Decidim::Messaging::ConversationHelper

        helper_method :suggestions, :suggestion, :notes_form

        def show
          enforce_permission_to :update, :suggestion_answer, suggestion: suggestion
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnswerSuggestionForm).from_model(suggestion)
        end

        def answer
          enforce_permission_to :update, :suggestion_answer, suggestion: suggestion
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnswerSuggestionForm).from_params(params)

          Admin::AnswerSuggestion.call(@form, suggestion) do
            on(:ok) do
              flash[:notice] = I18n.t("suggestions.answer.success", scope: "decidim.participatory_documents.admin")
              redirect_to document_suggestions_path(document)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("suggestions.answer.invalid", scope: "decidim.participatory_documents.admin")
              render action: "show"
            end
          end
        end

        private

        def notes_form
          @notes_form ||= form(Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm).from_params({})
        end

        def search_field_predicate
          :body_cont
        end

        def filters_with_values
          {
            state_eq: suggestion_stats
          }
        end

        def suggestion_stats
          Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES
        end

        def filters
          [
            :state_eq
          ]
        end

        def suggestions
          filtered_collection
        end

        def base_query
          Suggestion.where(suggestable: document).or(Suggestion.where(suggestable: document.sections))
        end

        def suggestion
          base_query.find(params[:id])
        end
      end
    end
  end
end
