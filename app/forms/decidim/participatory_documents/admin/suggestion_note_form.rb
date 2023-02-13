# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionNoteForm < Decidim::Form
        mimic :suggestion_note

        attribute :body, String

        validates :body, presence: true
      end
    end
  end
end
