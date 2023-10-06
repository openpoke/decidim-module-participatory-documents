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

      describe "with annotations" do
        let(:section1) { create :participatory_documents_section, document: document }
        let(:rect1) do
          {
            "top" => 20.0,
            "left" => 0.0
          }
        end
        let(:rect2) do
          {
            "top" => 10.0,
            "left" => 20.0
          }
        end
        let(:rect3) do
          {
            "top" => 10.0,
            "left" => 10.0
          }
        end
        let(:page1) { 1 }
        let(:page2) { 1 }
        let(:page3) { 1 }
        let(:section2) { create :participatory_documents_section, document: document }
        let(:section3) { create :participatory_documents_section, document: document }

        let!(:annotation1) { create(:participatory_documents_annotation, section: section1, rect: rect1, page_number: page1) }
        let!(:annotation2) { create(:participatory_documents_annotation, section: section2, rect: rect2, page_number: page2) }
        let!(:annotation3) { create(:participatory_documents_annotation, section: section3, rect: rect3, page_number: page3) }

        before do
          document.update_positions!
          annotation1&.reload
          annotation2&.reload
          annotation3&.reload
          section1&.reload
          section2&.reload
          section3&.reload
        end

        it "reorders annotations and sections" do
          expect(annotation1.position).to eq(3)
          expect(annotation2.position).to eq(2)
          expect(annotation3.position).to eq(1)
          expect(section1.position).to eq(3)
          expect(section2.position).to eq(2)
          expect(section3.position).to eq(1)
        end

        context "when repeating section3" do
          let(:section3) { section1 }

          it "reorders annotations and sections" do
            expect(annotation1.position).to eq(3)
            expect(annotation2.position).to eq(2)
            expect(annotation3.position).to eq(1)
            expect(section1.position).to eq(1)
            expect(section2.position).to eq(2)
            expect(section3.position).to eq(1)
          end
        end

        context "when repeating section2" do
          let(:section2) { section1 }

          it "reorders annotations and sections" do
            annotation1.save
            expect(annotation1.position).to eq(3)
            expect(annotation2.position).to eq(2)
            expect(annotation3.position).to eq(1)
            expect(section1.position).to eq(2)
            expect(section2.position).to eq(2)
            expect(section3.position).to eq(1)
          end
        end

        context "when different pages" do
          let(:page2) { 3 }
          let(:page3) { 2 }

          it "reorders annotations and sections" do
            expect(annotation1.position).to eq(1)
            expect(annotation2.position).to eq(3)
            expect(annotation3.position).to eq(2)
            expect(section1.position).to eq(1)
            expect(section2.position).to eq(3)
            expect(section3.position).to eq(2)
          end

          context "and repeating section3" do
            let(:section3) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.position).to eq(1)
              expect(annotation2.position).to eq(3)
              expect(annotation3.position).to eq(2)
              expect(section1.position).to eq(1)
              expect(section2.position).to eq(2)
              expect(section3.position).to eq(1)
            end
          end

          context "and repeating section2" do
            let(:section2) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.position).to eq(1)
              expect(annotation2.position).to eq(3)
              expect(annotation3.position).to eq(2)
              expect(section1.position).to eq(1)
              expect(section2.position).to eq(1)
              expect(section3.position).to eq(2)
            end
          end
        end

        context "when combined pages" do
          let(:page3) { 2 }

          it "reorders annotations and sections" do
            expect(annotation1.position).to eq(2)
            expect(annotation2.position).to eq(1)
            expect(annotation3.position).to eq(3)
            expect(section1.position).to eq(2)
            expect(section2.position).to eq(1)
            expect(section3.position).to eq(3)
          end

          context "and repeating section3" do
            let(:section3) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.position).to eq(2)
              expect(annotation2.position).to eq(1)
              expect(annotation3.position).to eq(3)
              expect(section1.position).to eq(2)
              expect(section2.position).to eq(1)
              expect(section3.position).to eq(2)
            end
          end

          context "and repeating section2" do
            let(:section2) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.position).to eq(2)
              expect(annotation2.position).to eq(1)
              expect(annotation3.position).to eq(3)
              expect(section1.position).to eq(1)
              expect(section2.position).to eq(1)
              expect(section3.position).to eq(2)
            end
          end
        end

        context "when no annotations" do
          let(:annotation1) { nil }
          let(:annotation2) { nil }
          let(:annotation3) { nil }

          it "sections are not reordered" do
            expect(section1.position).to eq(0)
            expect(section2.position).to eq(0)
            expect(section3.position).to eq(0)
          end
        end
      end
    end
  end
end