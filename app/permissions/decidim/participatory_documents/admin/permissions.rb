# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          handle_valuator_permissions if user_is_valuator?
          handle_general_permissions unless user_is_valuator?

          permission_action
        end

        private

        def handle_valuator_permissions
          if valuator_assigned_to_suggestion?
            can_create_suggestion_note?
            can_create_suggestion_answer?
            valuator_can_assign_or_unassign_valuator_from_suggestions?
            allow! if action_is_show_on_suggestion?
          elsif action_is_show_on_suggestion?
            disallow!
          end
        end

        def handle_general_permissions
          allow! if action_is_show_on_suggestion?
          if create_permission_action?
            can_create_suggestion_note?
            can_create_suggestion_answer?
          end
          edit_suggestion_note?
          can_edit_document_or_sections? if action_is_update_on_document?
          allow_default_admin_actions
        end

        def action_is_show_on_suggestion?
          permission_action.subject == :suggestion && permission_action.action == :show
        end

        def action_is_update_on_document?
          permission_action.subject == :participatory_document && permission_action.action == :update
        end

        def allow_default_admin_actions
          allow! if permission_action.subject == :suggestion_note && permission_action.action == :create
          allow! if permission_action.subject == :suggestion_answer
          allow! if permission_action.subject == :document_section
          allow! if permission_action.subject == :document_annotations
          allow! if permission_action.subject == :participatory_document && permission_action.action == :create
          allow! if permission_action.subject == :suggestions
        end

        def suggestion
          @suggestion ||= context.fetch(:suggestion, nil)
        end

        def document
          @document ||= context.fetch(:document, nil)
        end

        # There's no special condition to create proposal notes, only
        # users with access to the admin section can do it.
        def can_create_suggestion_note?
          allow! if permission_action.subject == :suggestion_note
        end

        # Documents can only be edited and sections added to them
        # if they are not finally published.
        def can_edit_document_or_sections?
          toggle_allow(!document.published?)
        end

        # Proposals can only be answered from the admin when the
        # corresponding setting is enabled.
        def can_create_suggestion_answer?
          toggle_allow(admin_suggestion_answering_is_enabled?) if permission_action.subject == :suggestion_answer
        end

        def create_permission_action?
          permission_action.action == :create
        end

        def valuator_can_assign_or_unassign_valuator_from_suggestions?
          allow! if permission_action.action == :unassign_from_valuator || permission_action.action == :assign_to_valuator
        end

        def admin_suggestion_answering_is_enabled?
          current_settings.try(:suggestion_answering_enabled) &&
            component_settings.try(:suggestion_answering_enabled)
        end

        def user_is_valuator?
          return false if user.admin?

          user_valuator_role.present?
        end

        def valuator_assigned_to_suggestion?
          @valuator_assigned_to_suggestion ||=
            Decidim::ParticipatoryDocuments::ValuationAssignment
            .where(suggestion:, valuator_role: user_valuator_role)
            .any?
        end

        def user_valuator_role
          @user_valuator_role ||= space.user_roles(:valuator).find_by(user:)
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
