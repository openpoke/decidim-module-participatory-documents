# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionsController < Admin::ApplicationController
        include Decidim::Admin::Filterable
        include Decidim::Admin::Paginable
        helper Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
        helper Decidim::Messaging::ConversationHelper

        helper_method :suggestions, :suggestion, :notes_form, :find_valuators_for_select

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

        def filters
          [
            :state_eq,
            :valuator_role_ids_has,
            :dummy_author_ids_has
          ]
        end

        def filters_with_values
          {
            state_eq: suggestion_stats,
            valuator_role_ids_has: valuator_role_ids,
            dummy_author_ids_has: author_ids
          }
        end

        def author_ids
          base_query.pluck(:decidim_author_id)
        end

        def valuator_role_ids
          current_participatory_space.user_roles(:valuator).pluck(:id)
        end

        # Can't user `super` here, because it does not belong to a superclass
        # but to a concern.
        def dynamically_translated_filters
          [:valuator_role_ids_has, :dummy_author_ids_has]
        end

        def suggestion_stats
          Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES
        end

        def translated_dummy_author_ids_has(value)
          Decidim::UserBaseEntity.find_by(id: value).try(:name)
        end

        def translated_valuator_role_ids_has(valuator_role_id)
          user_role = current_participatory_space.user_roles(:valuator).find_by(id: valuator_role_id)
          user_role&.user&.name
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

        # Internal: A method to cache to queries to find the valuators for the
        # current space.
        def find_valuators_for_select(participatory_space)
          return @valuators_for_select if @valuators_for_select

          valuator_roles = participatory_space.user_roles(:valuator)
          valuators = Decidim::User.where(id: valuator_roles.pluck(:decidim_user_id)).to_a

          @valuators_for_select = valuator_roles.map do |role|
            valuator = valuators.find { |user| user.id == role.decidim_user_id }

            [valuator.name, role.id]
          end
        end
      end
    end
  end
end
