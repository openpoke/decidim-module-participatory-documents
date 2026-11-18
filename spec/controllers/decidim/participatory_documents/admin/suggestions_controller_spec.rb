# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe SuggestionsController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { create(:participatory_documents_component) }
        let!(:document) { create(:participatory_documents_document, component:) }
        let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let!(:other_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }
        let(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
        let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET index" do
          let(:params) { { document_id: document.id } }

          it "lists every suggestion of the document" do
            get(:index, params:)

            expect(controller.helpers.suggestions).to contain_exactly(suggestion, other_suggestion)
          end

          context "when the administrator also has an evaluator role" do
            before { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process:) }

            it "lists every suggestion of the document" do
              get(:index, params:)

              expect(controller.helpers.suggestions).to contain_exactly(suggestion, other_suggestion)
            end
          end

          context "when the user is an evaluator" do
            let(:user) { evaluator }

            before { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

            it "lists only the suggestions assigned to them" do
              get(:index, params:)

              expect(controller.helpers.suggestions).to contain_exactly(suggestion)
            end
          end

          context "when the user is a collaborator of the space" do
            let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }

            before { create(:participatory_process_user_role, role: :collaborator, user:, participatory_process:) }

            it "lists every suggestion of the document" do
              get(:index, params:)

              expect(controller.helpers.suggestions).to contain_exactly(suggestion, other_suggestion)
            end
          end
        end

        describe "GET show" do
          let(:other_component) { create(:participatory_documents_component, participatory_space: participatory_process) }
          let(:other_document) { create(:participatory_documents_document, component: other_component) }
          let(:foreign_suggestion) { create(:participatory_documents_suggestion, suggestable: other_document) }

          it "does not find a suggestion of another document" do
            expect { get :show, params: { document_id: document.id, id: foreign_suggestion.id } }.to raise_error(ActiveRecord::RecordNotFound)
          end

          context "when the user is an evaluator not assigned to the suggestion" do
            let(:user) { evaluator }

            before { evaluator_role }

            it "does not authorize the evaluator" do
              get :show, params: { document_id: document.id, id: suggestion.id }

              expect(flash[:alert]).to eq("You are not authorized to perform this action.")
            end
          end
        end

        describe "POST publish_answers" do
          render_views

          let(:params) { { document_id: document.id } }

          it "asks to select a suggestion when none is selected" do
            post(:publish_answers, params:, xhr: true)

            expect(response).to have_http_status(:ok)
            expect(response.body).to include("Please select a suggestion")
          end
        end

        describe "PATCH answer" do
          let(:params) { { document_id: document.id, id: suggestion.id, answer_suggestion: { state: "accepted", answer: { en: "An answer" } } } }

          before { allow(controller).to receive(:document_suggestions_path).and_return("/suggestions") }

          it "answers the suggestion" do
            patch(:answer, params:)

            expect(suggestion.reload.state).to eq("accepted")
          end

          context "when the user is an evaluator" do
            let(:user) { evaluator }

            before { evaluator_role }

            context "and is assigned to the suggestion" do
              before { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

              it "answers the suggestion" do
                patch(:answer, params:)

                expect(suggestion.reload.state).to eq("accepted")
              end
            end

            context "and is not assigned to the suggestion" do
              it "does not answer the suggestion" do
                patch(:answer, params:)

                expect(suggestion.reload.state).to eq("not_answered")
                expect(flash[:alert]).to eq("You are not authorized to perform this action.")
              end
            end
          end
        end
      end
    end
  end
end
