# frozen_string_literal: true

require "spec_helper"

describe "Participatory documents component" do # rubocop:disable RSpec/DescribeClass
  let!(:document) { create(:participatory_documents_document) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let!(:another_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:component) { document.component }
  let(:manifest) { component.manifest.export_manifests.find { |manifest| manifest.name == :suggestions } }
  let(:collection) { manifest.collection.call(component, user, context) }
  let(:context) { nil }
  let(:user) { nil }

  describe "suggestions export" do
    it "exports the suggestions of all the users" do
      expect(collection).to include(suggestion)
      expect(collection).to include(another_suggestion)
      expect(collection.map(&:author).uniq.count).to eq(2)
    end

    context "when the user is specified" do
      let(:user) { suggestion.author }
      let(:context) { :my_suggestions }

      it "exports only the suggestions of the user" do
        expect(collection).to include(suggestion)
        expect(collection).not_to include(another_suggestion)
      end
    end

    context "when their own suggestions are requested without a user" do
      let(:context) { :my_suggestions }

      it "exports nothing" do
        expect(collection).to be_empty
      end
    end

    context "when the user is an evaluator" do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: component.participatory_space) }

      before { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

      it "exports only the suggestions assigned to them" do
        expect(collection).to contain_exactly(suggestion)
      end
    end
  end
end
