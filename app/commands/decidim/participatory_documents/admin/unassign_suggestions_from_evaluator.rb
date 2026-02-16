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
            form.evaluator_roles.each do |evaluator_role|
              form.suggestions.each do |suggestion|
                assignment = find_assignment(suggestion, evaluator_role)
                unassign(assignment) if assignment
              end
            end
          end
        end

        def find_assignment(suggestion, evaluator_role)
          Decidim::ParticipatoryDocuments::EvaluationAssignment.find_by(
            suggestion:,
            evaluator_role:
          )
        end

        def unassign(assignment)
          Decidim.traceability.perform_action!(
            :delete,
            assignment,
            form.current_user,
            suggestion: assignment.suggestion.id
          ) do
            assignment.destroy!
          end
        end
      end
    end
  end
end
