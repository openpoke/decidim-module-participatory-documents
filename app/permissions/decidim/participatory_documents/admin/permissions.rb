# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          handle_evaluator_permissions if user_is_evaluator?
          handle_general_permissions unless user_is_evaluator?

          permission_action
        end

        private

        def handle_evaluator_permissions
          if evaluator_assigned_to_suggestion?
            can_create_suggestion_note? if create_permission_action?
            edit_suggestion_note?
            can_answer_suggestion?
            evaluator_can_assign_or_unassign_evaluator_from_suggestions?
            allow! if action_is_show_on_suggestion?
          elsif action_is_show_on_suggestion?
            disallow!
          end
        end

        def handle_general_permissions
          allow! if action_is_show_on_suggestion?
          can_create_suggestion_note? if create_permission_action?
          can_answer_suggestion?
          edit_suggestion_note?
          can_edit_document_or_sections?
          allow_default_admin_actions
        end

        def action_is_show_on_suggestion?
          permission_action.subject == :suggestion && permission_action.action == :show
        end

        def action_is_update_on_document?
          permission_action.subject == :participatory_document && permission_action.action == :update
        end

        def allow_default_admin_actions
          allow! if permission_action.subject == :suggestion_answer && permission_action.action == :publish_answers
          allow! if permission_action.subject == :participatory_document && permission_action.action == :create
          allow! if permission_action.subject == :suggestions
        end

        def suggestion
          @suggestion ||= context.fetch(:suggestion, nil)
        end

        def document
          @document ||= context.fetch(:document, nil)
        end

        # There's no special condition to create suggestion notes, only
        # users with access to the admin section can do it.
        def can_create_suggestion_note?
          allow! if permission_action.subject == :suggestion_note
        end

        # Documents can only be edited and sections added to them
        # if they are not finally published.
        def can_edit_document_or_sections?
          toggle_allow(document.present? && !document.published?) if action_is_update_on_document? || action_is_on_sections_or_annotations?
        end

        def action_is_on_sections_or_annotations?
          [:document_section, :document_annotations].include?(permission_action.subject)
        end

        # Suggestions can only be answered from the admin when the
        # corresponding setting is enabled.
        def can_answer_suggestion?
          toggle_allow(admin_suggestion_answering_is_enabled?) if permission_action.subject == :suggestion_answer && permission_action.action == :update
        end

        def create_permission_action?
          permission_action.action == :create
        end

        def evaluator_can_assign_or_unassign_evaluator_from_suggestions?
          allow! if permission_action.action == :assign_to_evaluator
          allow! if permission_action.action == :unassign_from_evaluator && context[:evaluator] == user
        end

        def admin_suggestion_answering_is_enabled?
          component_settings.try(:suggestion_answering_enabled)
        end

        def user_is_evaluator?
          return false if user.admin?

          user_evaluator_role.present?
        end

        def evaluator_assigned_to_suggestion?
          @evaluator_assigned_to_suggestion ||=
            Decidim::ParticipatoryDocuments::EvaluationAssignment
            .where(suggestion:, evaluator_role: user_evaluator_role)
            .any?
        end

        def user_evaluator_role
          @user_evaluator_role ||= space.user_roles(:evaluator).find_by(user:)
        end

        def edit_suggestion_note?
          return false unless permission_action.action == :edit_note && permission_action.subject == :suggestion_note

          toggle_allow(suggestion_note_author?)
        end

        def suggestion_note_author?
          context[:suggestion_note].try(:author) == user
        end
      end
    end
  end
end
