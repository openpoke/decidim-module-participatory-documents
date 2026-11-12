# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe SuggestionNotesController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { create(:participatory_documents_component) }
        let!(:document) { create(:participatory_documents_document, component:) }
        let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }

        let(:other_document) { create(:participatory_documents_document) }
        let(:other_suggestion) { create(:participatory_documents_suggestion, suggestable: other_document) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "POST create" do
          let(:params) { { document_id: document.id, suggestion_id: suggestion.id, suggestion_note: { body: "A private note" } } }

          before { allow(controller).to receive(:document_suggestion_path).and_return("/suggestion") }

          it "creates a note for a suggestion of the current document" do
            expect { post(:create, params:) }.to change(SuggestionNote, :count).by(1)
          end

          context "when the suggestion belongs to another component" do
            let(:params) { { document_id: document.id, suggestion_id: other_suggestion.id, suggestion_note: { body: "A private note" } } }

            it "does not find the suggestion" do
              expect { post(:create, params:) }.to raise_error(ActiveRecord::RecordNotFound)
              expect(SuggestionNote.count).to eq(0)
            end
          end

          context "when the user is an evaluator" do
            let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
            let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process:) }

            context "and is assigned to the suggestion" do
              before { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

              it "creates the note" do
                expect { post(:create, params:) }.to change(SuggestionNote, :count).by(1)
              end
            end

            context "and is not assigned to the suggestion" do
              it "does not create the note" do
                expect { post(:create, params:) }.not_to change(SuggestionNote, :count)
              end
            end
          end
        end

        describe "PATCH update" do
          let(:note) { create(:participatory_documents_suggestion_note, suggestion:, author: user) }
          let(:params) { { document_id: document.id, suggestion_id: suggestion.id, id: note.id, suggestion_note: { body: "An updated note" } } }

          it "updates a note of the given suggestion" do
            patch(:update, params:)

            expect(note.reload.body).to eq("An updated note")
          end

          context "when the note belongs to a suggestion of another component" do
            let(:other_note) { create(:participatory_documents_suggestion_note, suggestion: other_suggestion, author: user) }
            let(:params) { { document_id: document.id, suggestion_id: suggestion.id, id: other_note.id, suggestion_note: { body: "An updated note" } } }

            it "does not find the note" do
              expect { patch(:update, params:) }.to raise_error(ActiveRecord::RecordNotFound)
              expect(other_note.reload.body).not_to eq("An updated note")
            end
          end
        end
      end
    end
  end
end
