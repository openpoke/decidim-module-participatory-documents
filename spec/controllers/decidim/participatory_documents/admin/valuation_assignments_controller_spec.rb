# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      RSpec.describe ValuationAssignmentsController, type: :controller do
        routes { Decidim::ParticipatoryDocuments::AdminEngine.routes }

        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { create :participatory_documents_component }
        let(:document) { create :participatory_documents_document, :with_suggestions, component: component }
        let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:valuator) { create(:user, :confirmed, :admin_terms_accepted, organization: organization) }
        let(:valuator2) { create :user, :confirmed, :admin_terms_accepted, organization: organization }
        let(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }
        let(:valuator_role2) { create :participatory_process_user_role, role: :valuator, user: valuator2, participatory_process: participatory_process }
        let(:non_valuator_user) { create(:user, :confirmed, organization: organization) }

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
              id: valuator_role2.id
            }
          end

          context "when valuator is assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role) }

            it "allows assigning a valuator to a suggestion" do
              sign_in valuator

              expect do
                post :create, params: create_params
              end.to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count).by(1)

              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(EngineRouter.admin_proxy(component).root_path)
            end
          end

          context "when valuator is not assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role2) }

            it "does not allow assigning a valuator to a suggestion" do
              sign_in valuator

              expect do
                post :create, params: create_params
              end.not_to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count)

              expect(flash[:alert]).to be_present
            end
          end
        end

        describe "DELETE destroy" do
          let(:destroy_params) do
            {
              document_id: document.id,
              id: valuator_role.id,
              suggestion_ids: [suggestion.id]
            }
          end

          context "when valuator is assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role) }

            it "allows unassigning a valuator from a suggestion" do
              sign_in valuator

              expect do
                delete :destroy, params: destroy_params
              end.to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count).by(-1)

              expect(flash[:notice]).to be_present
              expect(response).to redirect_to(EngineRouter.admin_proxy(component).root_path)
            end
          end

          context "when valuator is not assigned to a suggestion" do
            let!(:assignment) { create(:suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role2) }

            it "does not allow unassigning a valuator from a suggestion" do
              sign_in valuator

              expect do
                delete :destroy, params: destroy_params
              end.not_to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count)
            end
          end
        end
      end
    end
  end
end
