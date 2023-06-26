# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          # Valuators can only perform these actions
          if user_is_valuator?
            if valuator_assigned_to_suggestion?
              can_create_suggestion_note?
              can_create_suggestion_answer?
            end
            valuator_can_unassign_valuator_from_suggestions?

            return permission_action
          end

          if create_permission_action?
            can_create_suggestion_note?
            can_create_suggestion_answer?
          end

          edit_suggestion_note?

          can_edit_document_or_sections? if permission_action.subject == :participatory_document && permission_action.action == :update

          allow! if permission_action.subject == :suggestion_note && permission_action.action == :create
          allow! if permission_action.subject == :suggestion_answer
          allow! if permission_action.subject == :document_section
          allow! if permission_action.subject == :document_annotations
          allow! if permission_action.subject == :participatory_document && permission_action.action == :create
          allow! if permission_action.subject == :suggestions

          permission_action
        end

        private

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

        def can_unassign_valuator_from_suggestions?
          allow! if permission_action.subject == :suggestions && permission_action.action == :unassign_from_valuator
        end

        def valuator_can_unassign_valuator_from_suggestions?
          can_unassign_valuator_from_suggestions? if user == context.fetch(:valuator, nil)

          return unless permission_action.action == :assign_to_valuator && permission_action.subject == :suggestions

          allow!
        end

        def admin_suggestion_answering_is_enabled?
          current_settings.try(:suggestion_answering_enabled) &&
            component_settings.try(:suggestion_answering_enabled)
        end

        def user_is_valuator?
          return if user.admin?

          user_valuator_role.present?
        end

        def valuator_assigned_to_suggestion?
          @valuator_assigned_to_suggestion ||=
            Decidim::ParticipatoryDocuments::ValuationAssignment
            .where(suggestion: suggestion, valuator_role: user_valuator_role)
            .any?
        end

        def user_valuator_role
          @user_valuator_role ||= space.user_roles(:valuator).find_by(user: user)
        end

        def edit_suggestion_note?
          return unless permission_action.action == :edit_note && permission_action.subject == :suggestion_note

          toggle_allow(suggestion_note_author?)
        end

        def suggestion_note_author?
          context[:suggestion_note].try(:author) == user
        end
      end
    end
  end
end
