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

          store_initial_suggestion_state

          suggestion.assign_attributes(attributes)
          if (%w(state answer answer_is_published) & suggestion.changed).any?
            transaction { answer_suggestion }
            notify_suggestion_answer
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :suggestion, :initial_state, :signature

        def attributes
          {
            state: form.state,
            answer: form.answer,
            answer_is_published: form.answer_is_published,
            answered_at: %w(not_answered withdrawn).include?(form.state) ? nil : Time.current
          }
        end

        def answer_suggestion
          Decidim.traceability.perform_action!("answer", suggestion, form.current_user) do
            suggestion.save!
            suggestion
          end
        end

        def notify_suggestion_answer
          suggestion.reload
          return unless suggestion.answered? && suggestion.answer_is_published?

          NotifySuggestionAnswer.call(suggestion, initial_state)
        end

        def store_initial_suggestion_state
          @initial_state = suggestion.state
        end
      end
    end
  end
end
