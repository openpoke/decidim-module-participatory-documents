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
        it { expect(described_class.reflect_on_association(:suggestions).macro).to eq(:has_many) }
      end

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      describe ".title" do
        context "when is being provided" do
          it "returns input value" do
            expect(translated(subject.title)).not_to eq("Foo Bar")
            subject.title = { I18n.locale => "Foo Bar" }
            subject.save!
            subject.reload
            expect(translated(subject.title)).to eq("Foo Bar")
          end
        end

        context "when is not being provided" do
          let(:position) { 1 }
          let(:section) { create(:participatory_documents_section, title: nil, position: position) }

          it "returns computed value" do
            expect(translated(subject.title)).to eq("Section 1")
          end

          context "when has an intermediary position" do
            let(:position) { 5 }

            it "returns computed value" do
              expect(translated(subject.title)).to eq("Section 5")
            end
          end
        end
      end
    end
  end
end
