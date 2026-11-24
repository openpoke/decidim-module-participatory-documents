# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments::Admin
  describe UpdateSuggestionNote do
    let(:command) { described_class.new(form, note) }

    let!(:document) { create(:participatory_documents_document, :with_file) }
    let!(:note) { create(:participatory_documents_suggestion_note, suggestion:) }
    let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
    let(:form) { Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm.from_params(form_params) }

    describe "call" do
      let(:form_params) { { body: } }

      context "when the form is valid" do
        let(:body) { "Test body" }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the note" do
          expect { command.call }.to change(note, :body).to("Test body")
        end
      end

      context "when the body is left blank" do
        let(:body) { "" }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
