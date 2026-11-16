# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments
  describe MySuggestionSerializer do
    include Decidim::TranslationsHelper

    subject { described_class.new(suggestion) }
    let(:suggestion) { create(:participatory_documents_suggestion, :accepted, :draft, :with_answer) }
    let(:serialized) { subject.serialize }

    describe "serialize" do
      it "returns a hash with the serialized data for the suggestion" do
        expect(serialized).to include(id: suggestion.id)
        expect(serialized).to include(author: suggestion.author_name)
        expect(serialized).to include(section: translated_attribute(suggestion.suggestable.title))
        expect(serialized).not_to have_key(:state)
        expect(serialized).not_to have_key(:evaluators)
        expect(serialized).to include(submitted_on: I18n.l(suggestion.created_at, format: :decidim_short))
      end

      it "does not include the answer while it is not published" do
        expect(serialized).to include(answer: nil)
      end

      context "when the answer is published" do
        let(:suggestion) { create(:participatory_documents_suggestion, :accepted, :published, :with_answer) }

        it "includes the answer" do
          expect(serialized).to include(answer: translated_attribute(suggestion.answer))
        end
      end
    end
  end
end
