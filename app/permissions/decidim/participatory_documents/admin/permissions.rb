# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          if create_permission_action?
            can_create_suggestion_note?
            can_create_suggestion_answer?
          end
          allow! if permission_action.subject == :suggestion_note
          allow! if permission_action.subject == :suggestion_answer
          allow! if permission_action.subject == :document_section
          allow! if permission_action.subject == :document_annotations
          allow! if permission_action.subject == :participatory_document

          permission_action
        end

        private

        # There's no special condition to create proposal notes, only
        # users with access to the admin section can do it.
        def can_create_suggestion_note?
          allow! if permission_action.subject == :suggestion_note
        end

        def can_create_suggestion_answer?
          allow! if permission_action.subject == :suggestion_answer
        end

        def create_permission_action?
          permission_action.action == :create
        end
      end
    end
  end
end
