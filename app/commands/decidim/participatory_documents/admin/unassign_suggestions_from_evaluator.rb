# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UnassignSuggestionsFromEvaluator < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          unassign_suggestions
          broadcast(:ok)
        end

        private

        attr_reader :form

        def unassign_suggestions
          transaction do
            assignments.each { |assignment| unassign(assignment) }
          end
        end

        def assignments
          Decidim::ParticipatoryDocuments::EvaluationAssignment # rubocop:disable Decidim/OrganizationScopedFinder
            .where(suggestion: form.suggestions, evaluator_role: form.evaluator_roles)
            .includes(:suggestion)
        end

        def unassign(assignment)
          Decidim.traceability.perform_action!(
            :delete,
            assignment,
            form.current_user,
            suggestion_title: assignment.suggestion.body
          ) do
            assignment.destroy!
          end
        end
      end
    end
  end
end
