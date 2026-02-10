# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe EvaluationAssignment do
      subject { assignment }

      let(:evaluator) { create(:user, organization: component.organization) }
      let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }

      let(:participatory_process) { component.participatory_space }
      let(:component) { create(:participatory_documents_component) }
      let(:document) { create(:participatory_documents_document, component:) }
      let(:section1) { create(:participatory_documents_section, document:) }
      let(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

      context "when participatory_process_user_role is a evaluator" do
        let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

        it "destroys evaluation assignments when participatory_process_user_role is destroyed" do
          expect(Decidim::ParticipatoryDocuments::EvaluationAssignment.count).to eq(1)
          expect { evaluator_role.destroy }.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(-1)
        end
      end
    end
  end
end
