# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe ValuationAssignment do
      subject { assignment }

      let(:valuator) { create :user, organization: component.organization }
      let(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }

      let(:participatory_process) { component.participatory_space }
      let(:component) { create :participatory_documents_component }
      let(:document) { create :participatory_documents_document, component: component }
      let(:section1) { create(:participatory_documents_section, document: document) }
      let(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

      context "when participatory_process_user_role is a valuator" do
        let!(:assignment) { create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role }

        it "destroys valuation assignments when participatory_process_user_role is destroyed" do
          expect(Decidim::ParticipatoryDocuments::ValuationAssignment.count).to eq(1)
          expect { valuator_role.destroy }.to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count).by(-1)
        end
      end
    end
  end
end
