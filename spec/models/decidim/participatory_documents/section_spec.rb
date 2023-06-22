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

      describe "with annotations" do
        let(:section1) { create :participatory_documents_section }
        let(:section2) { create :participatory_documents_section, document: section1.document }
        let(:section3) { create :participatory_documents_section, document: section1.document }

        let!(:annotation1) { create(:participatory_documents_annotation, section: section1, rect: rect1, page_number: page1) }
        let!(:annotation2) { create(:participatory_documents_annotation, section: section2, rect: rect2, page_number: page2) }
        let!(:annotation3) { create(:participatory_documents_annotation, section: section3, rect: rect3, page_number: page3) }
        let(:next_section_annotations) { create_list :participatory_documents_annotation, 3 }

        let(:rect1) do
          {
            "top" => 20.0,
            "left" => 0.0,
            "width" => 0.0,
            "height" => 0.0
          }
        end
        let(:rect2) do
          {
            "top" => 10.0,
            "left" => 20.0,
            "width" => 0.0,
            "height" => 0.0
          }
        end
        let(:rect3) do
          {
            "top" => 10.0,
            "left" => 10.0,
            "width" => 0.0,
            "height" => 0.0
          }
        end
        let(:page1) { 1 }
        let(:page2) { 1 }
        let(:page3) { 1 }

        it "reorders annotations and sections" do
          expect(annotation1.reload.position).to eq(3)
          expect(annotation2.reload.position).to eq(2)
          expect(annotation3.reload.position).to eq(1)
          expect(section1.reload.position).to eq(3)
          expect(section2.reload.position).to eq(2)
          expect(section3.reload.position).to eq(1)
        end

        context "when repeating section3" do
          let(:section3) { section1 }

          it "reorders annotations and sections" do
            expect(annotation1.reload.position).to eq(3)
            expect(annotation2.reload.position).to eq(2)
            expect(annotation3.reload.position).to eq(1)
            expect(section1.reload.position).to eq(1)
            expect(section2.reload.position).to eq(2)
            expect(section3.reload.position).to eq(1)
          end
        end

        context "when repeating section2" do
          let(:section2) { section1 }

          it "reorders annotations and sections" do
            expect(annotation1.reload.position).to eq(3)
            expect(annotation2.reload.position).to eq(2)
            expect(annotation3.reload.position).to eq(1)
            expect(section1.reload.position).to eq(2)
            expect(section2.reload.position).to eq(2)
            expect(section3.reload.position).to eq(1)
          end
        end

        context "when different pages" do
          let(:page2) { 3 }
          let(:page3) { 2 }

          it "reorders annotations and sections" do
            expect(annotation1.reload.position).to eq(1)
            expect(annotation2.reload.position).to eq(3)
            expect(annotation3.reload.position).to eq(2)
            expect(section1.reload.position).to eq(1)
            expect(section2.reload.position).to eq(3)
            expect(section3.reload.position).to eq(2)
          end

          context "and repeating section3" do
            let(:section3) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.reload.position).to eq(1)
              expect(annotation2.reload.position).to eq(3)
              expect(annotation3.reload.position).to eq(2)
              expect(section1.reload.position).to eq(1)
              expect(section2.reload.position).to eq(2)
              expect(section3.reload.position).to eq(1)
            end
          end

          context "and repeating section2" do
            let(:section2) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.reload.position).to eq(1)
              expect(annotation2.reload.position).to eq(3)
              expect(annotation3.reload.position).to eq(2)
              expect(section1.reload.position).to eq(1)
              expect(section2.reload.position).to eq(1)
              expect(section3.reload.position).to eq(2)
            end
          end
        end

        context "when combined pages" do
          let(:page3) { 2 }

          it "reorders annotations and sections" do
            expect(annotation1.reload.position).to eq(2)
            expect(annotation2.reload.position).to eq(1)
            expect(annotation3.reload.position).to eq(3)
            expect(section1.reload.position).to eq(2)
            expect(section2.reload.position).to eq(1)
            expect(section3.reload.position).to eq(3)
          end

          context "and repeating section3" do
            let(:section3) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.reload.position).to eq(2)
              expect(annotation2.reload.position).to eq(1)
              expect(annotation3.reload.position).to eq(3)
              expect(section1.reload.position).to eq(2)
              expect(section2.reload.position).to eq(1)
              expect(section3.reload.position).to eq(2)
            end
          end

          context "and repeating section2" do
            let(:section2) { section1 }

            it "reorders annotations and sections" do
              expect(annotation1.reload.position).to eq(2)
              expect(annotation2.reload.position).to eq(1)
              expect(annotation3.reload.position).to eq(3)
              expect(section1.reload.position).to eq(1)
              expect(section2.reload.position).to eq(1)
              expect(section3.reload.position).to eq(2)
            end
          end
        end

        context "when no annotations" do
          let(:annotation1) { nil }
          let(:annotation2) { nil }
          let(:annotation3) { nil }

          it "sections are not reordered" do
            expect(section1.reload.position).to eq(0)
            expect(section2.reload.position).to eq(0)
            expect(section3.reload.position).to eq(0)
          end
        end
      end
    end
  end
end
