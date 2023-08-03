# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments
  describe EditSuggestionNoteModalCell, type: :cell do
    controller Decidim::ParticipatoryDocuments::Admin::SuggestionsController

    subject { cell(described_class, model, options).call }

    let(:suggestion_note) { create(:participatory_documents_suggestion_note) }
    let(:model) { suggestion_note }
    let!(:suggestion) { create(:participatory_documents_suggestion) }
    let(:options) { { modal_id: "editNoteModal", suggestion: suggestion } }

    context "when the suggestion note exists" do
      it "assigns the correct suggestion note body to the view" do
        expect(cell(described_class, model, options).note_body).to eq(suggestion_note.body)
      end
    end
  end
end
