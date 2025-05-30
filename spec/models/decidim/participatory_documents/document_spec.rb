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
        let(:first_section) { create(:participatory_documents_section, document:) }
        let(:first_rect) do
          {
            "top" => 20.0,
            "left" => 0.0
          }
        end
        let(:second_rect) do
          {
            "top" => 10.0,
            "left" => 20.0
          }
        end
        let(:third_rect) do
          {
            "top" => 10.0,
            "left" => 10.0
          }
        end
        let(:first_page) { 1 }
        let(:second_page) { 1 }
        let(:third_page) { 1 }
        let(:second_section) { create(:participatory_documents_section, document:) }
        let(:third_section) { create(:participatory_documents_section, document:) }

        let!(:first_annotation) { create(:participatory_documents_annotation, section: first_section, rect: first_rect, page_number: first_page) }
        let!(:second_annotation) { create(:participatory_documents_annotation, section: second_section, rect: second_rect, page_number: second_page) }
        let!(:third_annotation) { create(:participatory_documents_annotation, section: third_section, rect: third_rect, page_number: third_page) }

        before do
          document.update_positions!
          first_annotation&.reload
          second_annotation&.reload
          third_annotation&.reload
          first_section&.reload
          second_section&.reload
          third_section&.reload
        end

        it "reorders annotations and sections" do
          expect(first_annotation.position).to eq(3)
          expect(second_annotation.position).to eq(2)
          expect(third_annotation.position).to eq(1)
          expect(first_section.position).to eq(3)
          expect(second_section.position).to eq(2)
          expect(third_section.position).to eq(1)
        end

        context "when repeating third_section" do
          let(:third_section) { first_section }

          it "reorders annotations and sections" do
            expect(first_annotation.position).to eq(3)
            expect(second_annotation.position).to eq(2)
            expect(third_annotation.position).to eq(1)
            expect(first_section.position).to eq(1)
            expect(second_section.position).to eq(2)
            expect(third_section.position).to eq(1)
          end
        end

        context "when repeating second_section" do
          let(:second_section) { first_section }

          it "reorders annotations and sections" do
            first_annotation.save
            expect(first_annotation.position).to eq(3)
            expect(second_annotation.position).to eq(2)
            expect(third_annotation.position).to eq(1)
            expect(first_section.position).to eq(2)
            expect(second_section.position).to eq(2)
            expect(third_section.position).to eq(1)
          end
        end

        context "when different pages" do
          let(:second_page) { 3 }
          let(:third_page) { 2 }

          it "reorders annotations and sections" do
            expect(first_annotation.position).to eq(1)
            expect(second_annotation.position).to eq(3)
            expect(third_annotation.position).to eq(2)
            expect(first_section.position).to eq(1)
            expect(second_section.position).to eq(3)
            expect(third_section.position).to eq(2)
          end

          context "and repeating third_section" do
            let(:third_section) { first_section }

            it "reorders annotations and sections" do
              expect(first_annotation.position).to eq(1)
              expect(second_annotation.position).to eq(3)
              expect(third_annotation.position).to eq(2)
              expect(first_section.position).to eq(1)
              expect(second_section.position).to eq(2)
              expect(third_section.position).to eq(1)
            end
          end

          context "and repeating second_section" do
            let(:second_section) { first_section }

            it "reorders annotations and sections" do
              expect(first_annotation.position).to eq(1)
              expect(second_annotation.position).to eq(3)
              expect(third_annotation.position).to eq(2)
              expect(first_section.position).to eq(1)
              expect(second_section.position).to eq(1)
              expect(third_section.position).to eq(2)
            end
          end
        end

        context "when combined pages" do
          let(:third_page) { 2 }

          it "reorders annotations and sections" do
            expect(first_annotation.position).to eq(2)
            expect(second_annotation.position).to eq(1)
            expect(third_annotation.position).to eq(3)
            expect(first_section.position).to eq(2)
            expect(second_section.position).to eq(1)
            expect(third_section.position).to eq(3)
          end

          context "and repeating third_section" do
            let(:third_section) { first_section }

            it "reorders annotations and sections" do
              expect(first_annotation.position).to eq(2)
              expect(second_annotation.position).to eq(1)
              expect(third_annotation.position).to eq(3)
              expect(first_section.position).to eq(2)
              expect(second_section.position).to eq(1)
              expect(third_section.position).to eq(2)
            end
          end

          context "and repeating second_section" do
            let(:second_section) { first_section }

            it "reorders annotations and sections" do
              expect(first_annotation.position).to eq(2)
              expect(second_annotation.position).to eq(1)
              expect(third_annotation.position).to eq(3)
              expect(first_section.position).to eq(1)
              expect(second_section.position).to eq(1)
              expect(third_section.position).to eq(2)
            end
          end
        end

        context "when no annotations" do
          let(:first_annotation) { nil }
          let(:second_annotation) { nil }
          let(:third_annotation) { nil }

          it "sections are not reordered" do
            expect(first_section.position).to eq(0)
            expect(second_section.position).to eq(0)
            expect(third_section.position).to eq(0)
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
            Decidim::ParticipatoryDocuments.send(:remove_const, :Document)
            load "decidim/participatory_documents/document.rb"
          end

          after do
            Decidim::ParticipatoryDocuments.send(:remove_const, :Document)
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
            Decidim::ParticipatoryDocuments.send(:remove_const, :Document)
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
