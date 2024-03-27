# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe SuggestionNote do
      subject { suggestion_note }

      let!(:organization) { component.organization }
      let!(:participatory_process) { component.participatory_space }
      let(:component) { create(:participatory_documents_component) }

      let!(:author) { create(:user, :admin, organization:) }
      let!(:document) { create(:participatory_documents_document, component:) }
      let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document, author:) }
      let!(:suggestion_note) { build(:participatory_documents_suggestion_note, suggestion:, author:) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "has an associated author" do
        expect(suggestion_note.author).to be_a(Decidim::User)
      end

      it "has an associated proposal" do
        expect(suggestion_note.suggestion).to be_a(Decidim::ParticipatoryDocuments::Suggestion)
      end
    end
  end
end
