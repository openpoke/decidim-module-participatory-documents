# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionsController < Admin::ApplicationController
        include Decidim::Admin::Filterable
        include Decidim::Admin::Paginable
        helper Decidim::ParticipatoryDocuments::Admin::SuggestionHelper

        helper_method :suggestions, :suggestion, :document

        def show
          enforce_permission_to :update, :participatory_document, suggestion: suggestion
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnswerSuggestionForm).from_model(suggestion)
        end

        private

        def search_field_predicate
          :body_cont
        end

        def filters_with_values
          {
            state_eq: suggestion_stats
          }
        end

        def suggestion_stats
          Suggestion::POSSIBLE_STATES
        end

        def filters
          [
            :state_eq
          ]
        end

        def suggestions
          # filtered_collection
          paginate(filtered_collection)
        end

        def base_query
          Suggestion.where(suggestable: document).or(Suggestion.where(suggestable: document.sections))
        end

        def suggestion
          base_query.find(params[:id])
        end

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
        end
      end
    end
  end
end
