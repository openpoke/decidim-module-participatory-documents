# frozen_string_literal: true
module Decidim
  module ParticipatoryDocuments
    class SuggestionForm < Decidim::Form
      attribute :description, String
      validates :description, presence: true, length: { in: 15..150 }
    end
  end
end
