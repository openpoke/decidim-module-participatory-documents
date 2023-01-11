# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Suggestion do
      subject { suggestion }

      let(:suggestion) { create(:participatory_documents_suggestion) }

      include_examples "authorable" do
        subject { suggestion }
      end

      it { is_expected.to be_valid }
    end
  end
end
