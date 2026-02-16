# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class EvaluationAssignmentsController < Admin::ApplicationController
        def create
          @form = form(Admin::EvaluationAssignmentForm).from_params(params)

          @form.suggestions.each do |suggestion|
            enforce_permission_to :assign_to_evaluator, :suggestions, suggestion:
          end

          Admin::AssignSuggestionsToEvaluator.call(@form) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("evaluation_assignments.create.success", scope: "decidim.participatory_documents.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("evaluation_assignments.create.invalid", scope: "decidim.participatory_documents.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end

        def destroy
          @form = form(Admin::EvaluationAssignmentForm).from_params(destroy_params)

          @form.evaluator_roles.each do |evaluator_role|
            enforce_permission_to :unassign_from_evaluator, :suggestions, evaluator: evaluator_role.user
          end

          Admin::UnassignSuggestionsFromEvaluator.call(@form) do
            on(:ok) do |_proposal|
              flash.keep[:notice] = I18n.t("evaluation_assignments.delete.success", scope: "decidim.participatory_documents.admin")

              # If current user is one of the evaluators being unassigned, check if they still have access
              if current_user_is_being_unassigned?
                redirect_to EngineRouter.admin_proxy(current_component).root_path
              else
                redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
              end
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("evaluation_assignments.delete.invalid", scope: "decidim.participatory_documents.admin")
              redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end

        private

        def destroy_params
          if params[:suggestion_id].present?
            {
              suggestion_ids: [params[:suggestion_id]],
              evaluator_role_ids: [params[:id]]
            }
          else
            params.permit(suggestion_ids: [], evaluator_role_ids: []).to_h
          end
        end

        def current_user_is_being_unassigned?
          return false unless current_user.present? && !current_user.admin?

          # Check if current_user is one of the evaluator roles being unassigned
          @form.evaluator_roles.any? { |role| role.user == current_user }
        end

        def skip_manage_component_permission
          true
        end
      end
    end
  end
end
