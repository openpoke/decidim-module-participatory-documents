# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe AnnotationForm do
        subject { described_class.from_params(attributes) }

        let(:rect) do
          { "left" => 0, "top" => 50, "width" => 100, "height" => 100 }
        end
        let(:attributes) do
          {
            "rect" => rect
          }
        end

        it { is_expected.to be_valid }

        context "when rect is not valid" do
          let(:rect) do
            { "left" => 50 }
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
