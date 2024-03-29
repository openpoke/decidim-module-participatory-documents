# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments
  describe MySuggestionSerializer do
    include Decidim::TranslationsHelper
    include Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
    include ActionView::Helpers::TextHelper

    subject { described_class.new(suggestion) }
    let(:suggestion) { create(:participatory_documents_suggestion, :with_answer) }
    let(:serialized) { subject.serialize }

    describe "serialize" do
      it "returns a hash with the serialized data for the suggestion" do
        expect(serialized).to include(id: suggestion.id)
        expect(serialized).to include(author: suggestion.try(:normalized_author).try(:name))
        expect(serialized).to include(state: humanize_suggestion_state(suggestion.state))
        expect(serialized).to include(section: translated_attribute(suggestion.suggestable.title))
        expect(serialized).not_to have_key(:valuators)
        expect(serialized).to include(submitted_on: I18n.l(suggestion.created_at, format: :decidim_short))
      end
    end
  end
end
