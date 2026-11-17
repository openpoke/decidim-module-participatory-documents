# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe EvaluationAssignmentsController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { create(:participatory_documents_component) }
        let(:document) { create(:participatory_documents_document, :with_suggestions, component:) }
        let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
        let(:evaluator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
        let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
        let(:evaluator_role2) { create(:participatory_process_user_role, role: :evaluator, user: evaluator2, participatory_process:) }
        let(:current_user) { evaluator }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "POST create" do
          let(:params) { { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [evaluator_role2.id] } }

          context "when the evaluator is assigned to the suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

            it "allows assigning an evaluator to the suggestion" do
              expect { post(:create, params:) }.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(1)

              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(EngineRouter.admin_proxy(component).root_path)
            end
          end

          context "when the evaluator is not assigned to the suggestion" do
            it "does not allow assigning an evaluator to the suggestion" do
              expect { post(:create, params:) }.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)

              expect(flash[:alert]).to eq("You are not authorized to perform this action.")
              expect(response).to redirect_to(controller.decidim_admin.root_path)
            end
          end
        end

        describe "DELETE destroy" do
          let(:params) { { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [assignment.evaluator_role.id] } }

          context "when the evaluator is assigned to the suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

            it "allows the evaluator to unassign themself from the suggestion" do
              expect { delete(:destroy, params:) }.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(-1)

              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(EngineRouter.admin_proxy(component).root_path)
            end

            context "and tries to unassign another evaluator" do
              let!(:other_assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role: evaluator_role2) }
              let(:params) { { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [evaluator_role2.id] } }

              it "does not allow unassigning the other evaluator" do
                expect { delete(:destroy, params:) }.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)

                expect(flash[:alert]).to eq("You are not authorized to perform this action.")
                expect(response).to redirect_to(controller.decidim_admin.root_path)
              end
            end
          end

          context "when the evaluator is not assigned to the suggestion" do
            let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role: evaluator_role2) }

            it "does not allow unassigning an evaluator from the suggestion" do
              expect { delete(:destroy, params:) }.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)

              expect(flash[:alert]).to eq("You are not authorized to perform this action.")
              expect(response).to redirect_to(controller.decidim_admin.root_path)
            end
          end
        end

        context "when the user is an admin of the space" do
          let(:current_user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
          let!(:admin_role) { create(:participatory_process_user_role, role: :admin, user: current_user, participatory_process:) }
          let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

          it "allows assigning an evaluator to the suggestion" do
            params = { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [evaluator_role2.id] }

            expect { post(:create, params:) }.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(1)
          end

          it "allows unassigning an evaluator from the suggestion" do
            params = { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [evaluator_role.id] }

            expect { delete(:destroy, params:) }.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(-1)
          end
        end

        context "when the user is a collaborator of the space" do
          let(:current_user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
          let!(:collaborator_role) { create(:participatory_process_user_role, role: :collaborator, user: current_user, participatory_process:) }
          let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

          it "does not allow assigning an evaluator to the suggestion" do
            params = { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [evaluator_role2.id] }

            expect { post(:create, params:) }.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)
            expect(flash[:alert]).to eq("You are not authorized to perform this action.")
          end

          it "does not allow unassigning an evaluator from the suggestion" do
            params = { document_id: document.id, suggestion_ids: [suggestion.id], evaluator_role_ids: [evaluator_role.id] }

            expect { delete(:destroy, params:) }.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)
            expect(flash[:alert]).to eq("You are not authorized to perform this action.")
          end
        end
      end
    end
  end
end
