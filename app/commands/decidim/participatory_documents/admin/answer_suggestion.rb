# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnswerSuggestion < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, suggestion)
          @form = form
          @suggestion = suggestion
        end

        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            answer_suggestion
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :suggestion

        def answer_suggestion
          Decidim.traceability.perform_action!(
            "answer",
            suggestion,
            form.current_user
          ) do
            attributes = {
              state: form.state,
              answer: form.answer,
              answer_is_draft: form.answer_is_draft
            }

            attributes[:answered_at] = if %w(not_answered withdrawn).include?(form.state)
                                         nil
                                       else
                                         Time.current
                                       end

            suggestion.update!(attributes)
            suggestion
          end
        end
      end
    end
  end
end
