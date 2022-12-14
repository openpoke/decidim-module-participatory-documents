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
    end
  end
end
