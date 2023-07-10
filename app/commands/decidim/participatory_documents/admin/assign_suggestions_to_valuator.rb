# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AssignSuggestionsToValuator < Decidim::Command
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

          assign_suggestions
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        private

        attr_reader :form

        def assign_suggestions
          transaction do
            form.suggestions.flat_map do |suggestion|
              find_assignment(suggestion) || assign_suggestion(suggestion)
            end
          end
        end

        def find_assignment(suggestion)
          Decidim::ParticipatoryDocuments::ValuationAssignment.find_by(
            suggestion: suggestion,
            valuator_role: form.valuator_role
          )
        end

        def assign_suggestion(suggestion)
          Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::ValuationAssignment,
            form.current_user,
            suggestion: suggestion,
            valuator_role: form.valuator_role
          )
        end
      end
    end
  end
end
