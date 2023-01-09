# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Section do
      subject { section }

      let(:section) { create(:participatory_documents_section) }

      describe "associations" do
        it { expect(described_class.reflect_on_association(:document).macro).to eq(:belongs_to) }
        it { expect(described_class.reflect_on_association(:annotations).macro).to eq(:has_many) }
      end

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }
    end
  end
end
