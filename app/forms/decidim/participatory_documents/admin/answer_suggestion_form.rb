# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnswerSuggestionForm < Decidim::Form
        include TranslatableAttributes
        translatable_attribute :answer, String
        attribute :internal_state, String

        validates :internal_state, presence: true, inclusion: { in: %w(not_answered accepted rejected evaluating) }
      end
    end
  end
end
