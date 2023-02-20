# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe AssignSuggestionsToValuator do
        subject { described_class.new(form) }

        let(:valid) { true }
        let(:organization) { component.organization }
        let!(:user) { create :user, :admin, :confirmed, organization: organization }

        let(:component) { create :participatory_documents_component }
        let(:document) { create :participatory_documents_document, component: component }
        let(:section1) { create(:participatory_documents_section, document: document) }
        let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
        let(:valuator) { create :user, organization: organization }

        let(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: component.participatory_space }

        let(:form) do
          double(
            current_organization: organization,
            current_user: user,
            valid?: valid,
            valuator_role: valuator_role,
            suggestions: [suggestion]
          )
        end

        context "when the form is valid" do
          it "saves the data when inexistent" do
            create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count).by(0)
            expect { subject.call }.to broadcast(:ok)
          end

          it "saves the data when inexistent" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::ValuationAssignment, :count).by(1)
            expect { subject.call }.to broadcast(:ok)
          end
        end

        context "when the form is not valid" do
          let(:valid) { false }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          context " when valuator is missing" do
            let(:valuator_role) {nil}
            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end

      end
    end
  end
end