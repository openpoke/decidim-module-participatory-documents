# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionsController < Admin::ApplicationController
        include Decidim::Admin::Filterable
        include Decidim::Paginable

        helper Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
        helper Decidim::Messaging::ConversationHelper

        helper_method :suggestions, :suggestion, :notes_form, :find_evaluators_for_select, :suggestion_ids,
                      :suggestion_find, :evaluator_assigned_to_suggestion?

        def show
          enforce_permission_to(:show, :suggestion, suggestion:)

          @form = form(Decidim::ParticipatoryDocuments::Admin::AnswerSuggestionForm).from_model(suggestion)
        end

        def answer
          enforce_permission_to(:update, :suggestion_answer, suggestion:)
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

        def publish_answers
          enforce_permission_to :publish_answers, :suggestion_answer

          Decidim::ParticipatoryDocuments::Admin::PublishAnswers.call(current_component, current_user, suggestion_ids) do
            on(:invalid) do
              flash.now[:alert] = I18n.t("suggestions.publish_answers.select_a_suggestion", scope: "decidim.participatory_documents.admin")
            end

            on(:ok) do
              flash.now[:notice] = I18n.t("suggestions.publish_answers.success", scope: "decidim.participatory_documents.admin")
            end
          end

          render "decidim/participatory_documents/admin/suggestions/publish_answers", formats: [:js]
        end

        private

        def suggestion_find(id)
          base_query.find(id)
        end

        def suggestion_ids
          @suggestion_ids ||= params[:suggestion_ids]
        end

        def notes_form
          @notes_form ||= form(Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm).from_params({})
        end

        def search_field_predicate
          :body_cont
        end

        def filters
          [
            :state_eq,
            :evaluator_role_ids_has,
            :dummy_author_ids_has,
            :dummy_suggestable_id_has
          ]
        end

        def filters_with_values
          {
            state_eq: suggestion_stats,
            evaluator_role_ids_has: evaluator_role_ids,
            dummy_author_ids_has: author_ids,
            dummy_suggestable_id_has: suggestable_ids
          }
        end

        def suggestable_ids
          ["d-#{document.id}"] + sections_by_id.keys.map { |id| "s-#{id}" }
        end

        def author_ids
          author_names.keys
        end

        def evaluator_role_ids
          evaluator_role_names.keys
        end

        # Can't user `super` here, because it does not belong to a superclass
        # but to a concern.
        def dynamically_translated_filters
          [:evaluator_role_ids_has, :dummy_author_ids_has, :dummy_suggestable_id_has]
        end

        def translated_dummy_suggestable_id_has(value)
          type, id = value.split("-")
          return t("decidim.participatory_documents.admin.suggestions.suggestion.global") if type == "d"

          translated_attribute(sections_by_id[id.to_i].try(:title))
        end

        def suggestion_stats
          Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES
        end

        def translated_dummy_author_ids_has(value)
          author_names[value.to_i]
        end

        def translated_evaluator_role_ids_has(evaluator_role_id)
          evaluator_role_names[evaluator_role_id.to_i]
        end

        def sections_by_id
          @sections_by_id ||= document.sections.index_by(&:id)
        end

        def author_names
          @author_names ||= current_organization.users.where(id: base_query.select(:decidim_author_id)).order(:name).pluck(:id, :name).to_h
        end

        def evaluator_role_names
          @evaluator_role_names ||= begin
            roles = current_participatory_space.user_roles(:evaluator)
            roles = roles.order_by_name if roles.respond_to?(:order_by_name)
            roles.to_h { |role| [role.id, role.user&.name] }
          end
        end

        def suggestions
          @suggestions ||= filtered_collection.preload(:author, :suggestable, file_attachment: :blob, evaluation_assignments: { evaluator_role: :user })
        end

        def base_query
          @base_query ||= if current_user.admin? || evaluator_roles.empty?
                            document.suggestions_including_sections
                          else
                            document.suggestions_including_sections.with_evaluation_assigned_to(current_user, current_participatory_space)
                          end
        end

        def suggestion
          return @suggestion if defined?(@suggestion)

          @suggestion = base_query.find_by(id: params[:id])
        end

        def find_evaluators_for_select(_participatory_space)
          evaluator_role_names.map { |id, name| [name, id] }
        end

        def evaluator_assigned_to_suggestion?
          return @evaluator_assigned_to_suggestion if defined?(@evaluator_assigned_to_suggestion)

          @evaluator_assigned_to_suggestion = suggestion.present? && suggestion.evaluation_assignments.where(evaluator_role: evaluator_roles).any?
        end

        def skip_manage_component_permission
          action_name == "answer" && evaluator_roles.exists?
        end
      end
    end
  end
end
