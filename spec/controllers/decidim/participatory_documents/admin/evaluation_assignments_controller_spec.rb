# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      RSpec.describe EvaluationAssignmentsController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { create(:participatory_documents_component) }
        let(:document) { create(:participatory_documents_document, :with_suggestions, component:) }
        let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
        let(:evaluator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
        let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
        let(:evaluator_role2) { create(:participatory_process_user_role, role: :evaluator, user: evaluator2, participatory_process:) }
        let(:non_evaluator_user) { create(:user, :confirmed, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
        end

        describe "POST create" do
          let(:create_params) do
            {
              document_id: document.id,
              suggestion_ids: [suggestion.id],
              evaluator_role_ids: [evaluator_role2.id]
            }
          end

          context "when evaluator is assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

            it "allows assigning an evaluator to a suggestion" do
              sign_in evaluator

              expect do
                post :create, params: create_params
              end.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(1)

              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(EngineRouter.admin_proxy(component).root_path)
            end
          end

          context "when evaluator is not assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role: evaluator_role2) }

            it "does not allow assigning an evaluator to a suggestion" do
              sign_in evaluator

              expect do
                post :create, params: create_params
              end.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)

              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "DELETE destroy" do
          let(:destroy_params) do
            {
              document_id: document.id,
              evaluator_role_ids: [evaluator_role.id],
              suggestion_ids: [suggestion.id]
            }
          end

          context "when evaluator is assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

            it "allows unassigning an evaluator from a suggestion" do
              sign_in evaluator

              expect do
                delete :destroy, params: destroy_params
              end.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(-1)

              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(EngineRouter.admin_proxy(component).root_path)
            end
          end

          context "when evaluator is not assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role: evaluator_role2) }

            it "does not allow unassigning an evaluator from a suggestion" do
              sign_in evaluator

              expect do
                delete :destroy, params: destroy_params
              end.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)
            end
          end
        end
      end
    end
  end
end
