# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Section do


      describe "associations" do
        it { expect(described_class.reflect_on_association(:document).macro).to eq(:belongs_to) }
        it { expect(described_class.reflect_on_association(:annotations).macro).to eq(:has_many) }
      end
    end
  end
end