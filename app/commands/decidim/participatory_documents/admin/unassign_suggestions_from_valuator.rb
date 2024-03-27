# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UnassignSuggestionsFromValuator < Decidim::Command
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
            form.suggestions.flat_map do |suggestion|
              assignment = find_assignment(suggestion)
              unassign(assignment) if assignment
            end
          end
        end

        def find_assignment(suggestion)
          Decidim::ParticipatoryDocuments::ValuationAssignment.find_by(
            suggestion:,
            valuator_role: form.valuator_role
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
