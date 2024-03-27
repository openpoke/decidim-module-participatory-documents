# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments::Admin
  describe UpdateSuggestionNote do
    let(:command) { described_class.new(form, note) }

    let!(:document) { create(:participatory_documents_document, :with_file) }
    let(:component) { document.component }
    let(:organization) { component.organization }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let!(:note) { create(:participatory_documents_suggestion_note, suggestion:) }
    let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }

    let(:form) do
      Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm.from_params(
        form_params
      )
    end

    describe "call" do
      let(:form_params) do
        { body: }
      end

      context "when the form is valid" do
        let(:body) { "Test body" }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the note" do
          expect do
            command.call
          end.to change(note, :body)
        end
      end

      context "when file_field :body is left blank" do
        let(:body) { "" }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
