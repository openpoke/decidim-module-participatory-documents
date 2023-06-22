# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Document do
      subject { document }

      let(:component) { build :participatory_documents_component }
      let(:organization) { component.participatory_space.organization }
      let(:document) { create(:participatory_documents_document, component: component) }
      let!(:author) { create(:user, organization: organization) }

      describe "associations" do
        it { expect(described_class.reflect_on_association(:suggestions).macro).to eq(:has_many) }
        it { expect(described_class.reflect_on_association(:sections).macro).to eq(:has_many) }
        it { expect(described_class.reflect_on_association(:annotations).macro).to eq(:has_many) }
      end

      it "has not suggestions" do
        expect(document).not_to be_has_suggestions
      end

      include_examples "has component"
      include_examples "authorable" do
        subject { document }
      end
      # include_examples "endorsable"
      # include_examples "has scope"
      # include_examples "has category"
      # include_examples "has reference"
      # include_examples "reportable"
      # include_examples "resourceable"

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      context "when has global suggestions" do
        let(:document) { create(:participatory_documents_document, :with_global_suggestions, component: component) }

        it "has suggestions" do
          expect(document).to be_has_suggestions
        end
      end

      context "when has section suggestions" do
        let(:document) { create(:participatory_documents_document, :with_suggestions, component: component) }

        it "has suggestions" do
          expect(document).to be_has_suggestions
        end
      end
    end
  end
end
