# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe CreateSuggestionNote do
        describe "call" do
          let(:document) { create(:participatory_documents_document) }
          let(:organization) { document.component.organization }
          let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
          let(:current_user) { create(:user, :admin, :confirmed, organization:) }
          let(:form) { SuggestionNoteForm.from_params(form_params).with_context(current_user:, current_organization: organization) }
          let(:form_params) { { body: } }
          let(:body) { "A reasonable private note" }
          let(:command) { described_class.new(form, suggestion) }

          describe "when the form is not valid" do
            let(:body) { "" }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create the suggestion note" do
              expect { command.call }.not_to change(SuggestionNote, :count)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the suggestion note" do
              expect { command.call }.to change(SuggestionNote, :count).by(1)
            end

            it "sets the body, the suggestion and the author of the note" do
              command.call

              suggestion_note = SuggestionNote.last
              expect(suggestion_note.body).to eq(body)
              expect(suggestion_note.suggestion).to eq(suggestion)
              expect(suggestion_note.author).to eq(current_user)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:create!)
                .with(SuggestionNote, current_user, hash_including(:body, :suggestion, :author))
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
            end
          end
        end
      end
    end
  end
end
