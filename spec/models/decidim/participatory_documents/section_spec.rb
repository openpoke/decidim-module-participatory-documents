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
          context "when is the first section" do
            let!(:after_section) { create_list(:participatory_documents_section, 2, document: section.document) }
            let(:section) { create(:participatory_documents_section, title: nil) }

            it "returns computed value" do
              expect(translated(subject.title)).to eq("Section 1")
              expect(subject.document.sections.size).to eq(3)
            end
          end

          context "when has an intermediary position" do
            let(:section_count) { 5 }
            let(:expected_position) { section_count + 1 }
            let(:document) { create(:participatory_documents_document) }
            let(:precedent_section) { create_list(:participatory_documents_section, section_count, document: document) }
            let(:section) { create(:participatory_documents_section, document: precedent_section.first.document, title: nil) }
            let!(:after_section) { create_list(:participatory_documents_section, section_count, document: section.document) }

            it "returns computed value" do
              expect(translated(subject.document.sections[5].title)).to eq("Section #{expected_position}")
              expect(subject.document.sections.size).to eq(expected_position + section_count)
            end
          end

          context "when is last" do
            let(:section_count) { 5 }
            let(:expected_position) { section_count + 1 }
            let(:document) { create(:participatory_documents_document) }
            let(:precedent_section) { create_list(:participatory_documents_section, section_count, document: document) }
            let(:section) { create(:participatory_documents_section, document: precedent_section.first.document, title: nil) }

            it "returns computed value" do
              expect(translated(subject.document.sections.last.title)).to eq("Section #{expected_position}")
              expect(subject.document.sections.size).to eq(expected_position)
            end
          end
        end
      end
    end
  end
end
