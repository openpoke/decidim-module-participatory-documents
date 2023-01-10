# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe SectionForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let(:organization) { create :organization }

        let(:attributes) do
          {
            "uuid" => "Randomuuid",
            "title" => {
              "en" => "Foo bar title",
              "ca" => "Foo bar title",
              "es" => "Foo bar title"
            },
            "description" => {
              "en" => "Foo bar description",
              "ca" => "Foo bar description",
              "es" => "Foo bar description"
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
