# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnswerSuggestionForm < Decidim::Form
        include TranslatableAttributes
        translatable_attribute :answer, String
        attribute :state, String, default: "not_answered"
        attribute :answer_is_published, Boolean, default: false

        validates :state, presence: true, inclusion: { in: %w(not_answered accepted rejected evaluating) }, unless: ->(form) { form.answer_is_published? }
        validates :state, presence: true, inclusion: { in: %w(accepted rejected evaluating) }, if: ->(form) { form.answer_is_published? }

        def answer_is_published?
          answer_is_published == true
        end
      end
    end
  end
end
