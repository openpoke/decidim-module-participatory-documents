# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AssignSuggestionsToEvaluator < Decidim::Command
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
            form.evaluator_roles.each do |evaluator_role|
              form.suggestions.each do |suggestion|
                find_assignment(suggestion, evaluator_role) || assign_suggestion(suggestion, evaluator_role)
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

        def assign_suggestion(suggestion, evaluator_role)
          Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::EvaluationAssignment,
            form.current_user,
            suggestion:,
            evaluator_role:
          )
        end
      end
    end
  end
end
