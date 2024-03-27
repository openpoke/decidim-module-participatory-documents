# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments
  describe SuggestionSerializer do
    include Decidim::TranslationsHelper
    include Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
    include ActionView::Helpers::TextHelper

    subject { described_class.new(suggestion) }
    let(:suggestion) { create(:participatory_documents_suggestion, :with_answer) }
    let!(:valuation_assignment) { create(:suggestion_valuation_assignment, suggestion:) }
    let(:serialized) { subject.serialize }

    describe "serialize" do
      it "returns a hash with the serialized data for the suggestion" do
        expect(serialized).to include(id: suggestion.id)
        expect(serialized).to include(author: suggestion.try(:normalized_author).try(:name))
        expect(serialized).to include(state: humanize_suggestion_state(suggestion.state))
        expect(serialized).to include(section: translated_attribute(suggestion.suggestable.title))
        expect(serialized).to include(valuators: valuation_assignment.valuator.name)
        expect(serialized).to include(submitted_on: I18n.l(suggestion.created_at, format: :decidim_short))
      end

      context "when :max_export_text_length > 0" do
        before do
          Decidim::ParticipatoryDocuments.max_export_text_length = 10
        end

        it "returns an answer that is 10 characters long" do
          expect(serialized).to include(answer: truncate(translated_attribute(suggestion.answer), length: 10))
          expect(serialized).to include(body: truncate(translated_attribute(suggestion.body), length: 10))
        end
      end

      context "when :max_export_text_length = 0" do
        before do
          Decidim::ParticipatoryDocuments.max_export_text_length = 0
        end

        it "returns the full answer" do
          expect(serialized).to include(answer: translated_attribute(suggestion.answer))
          expect(serialized).to include(body: translated_attribute(suggestion.body))
        end
      end
    end
  end
end
