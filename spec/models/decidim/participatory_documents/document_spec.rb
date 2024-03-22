# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Document do
      subject { document }

      let(:component) { build(:participatory_documents_component) }
      let(:organization) { component.participatory_space.organization }
      let(:document) { create(:participatory_documents_document, component:) }
      let!(:author) { create(:user, organization:) }

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
        let(:document) { create(:participatory_documents_document, :with_global_suggestions, component:) }

        it "has suggestions" do
          expect(document).to be_has_suggestions
        end
      end

      context "when has section suggestions" do
        let(:document) { create(:participatory_documents_document, :with_suggestions, component:) }

        it "has suggestions" do
          expect(document).to be_has_suggestions
        end
      end

      describe "with annotations" do
        let(:section1) { create(:participatory_documents_section, document:) }
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
        let(:section2) { create(:participatory_documents_section, document:) }
        let(:section3) { create(:participatory_documents_section, document:) }

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

      describe "antivirus compatibility" do
        let(:document) { build(:participatory_documents_document, component: nil, author: nil) }

        it "is invalid" do
          expect(document).not_to be_valid
          expect(document.errors.full_messages).to include("Component must exist")
          expect(document.errors.full_messages).to include("Author must exist")
          expect(document.errors.full_messages).to include("File The file is not attached to any organization")
        end

        context "when defined organization" do
          let(:document) { build(:participatory_documents_document, component: nil, author: nil, organization:) }

          it "does not complain about organization" do
            expect(document).not_to be_valid
            expect(document.errors.full_messages).to include("Component must exist")
            expect(document.errors.full_messages).to include("Author must exist")
            expect(document.errors.full_messages).not_to include("File The file is not attached to any organization")
          end
        end

        context "when not AntivirusValidator defined" do
          before do
            allow(ParticipatoryDocuments).to receive(:antivirus_enabled).and_return(false)
            Decidim::ParticipatoryDocuments.send(:stub_const, :Document)
            load "decidim/participatory_documents/document.rb"
          end

          after do
            Decidim::ParticipatoryDocuments.send(:stub_const, :Document)
            load "decidim/participatory_documents/document.rb"
          end

          it "has file validator only" do
            document = Document.new
            expect(document._validators[:file]).to include(an_instance_of(ActiveModel::Validations::FileSizeValidator))
            expect(document._validators[:file]).not_to include(an_instance_of(AntivirusValidator))
          end
        end

        context "when defined AntivirusValidator" do
          before do
            allow(ParticipatoryDocuments).to receive(:antivirus_enabled).and_return(true)
            Decidim::ParticipatoryDocuments.send(:stub_const, :Document)
            load "decidim/participatory_documents/document.rb"
          end

          it "has antivirus validator" do
            document = Document.new
            expect(document._validators[:file]).to include(an_instance_of(ActiveModel::Validations::FileSizeValidator))
            expect(document._validators[:file]).to include(an_instance_of(AntivirusValidator))
          end
        end
      end
    end
  end
end
