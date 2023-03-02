# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DocumentForm do
        subject { described_class.from_params(attributes) }

        let(:attributes) do
          {
            "title" => {
              "en" => "My title",
              "ca" => "El meu títol",
              "es" => "Mi título"
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
