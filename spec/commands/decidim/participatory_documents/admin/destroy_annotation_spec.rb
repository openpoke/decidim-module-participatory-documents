# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DestroyAnnotation do
        subject { described_class.new(form, annotation.section.document) }

        let!(:annotation) { create(:participatory_documents_annotation) }
        let(:user) { annotation.section.document.author }
        let(:invalid) { false }

        let(:form) do
          double(
            invalid?: invalid,
            id: annotation.id,
            current_user: user
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          let!(:another_annotation) { create(:participatory_documents_annotation, section: another_section) }
          let(:another_section) { create(:participatory_documents_section, document: annotation.section.document) }

          it "Removes a annotation" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Annotation, :count).by(-1)
          end

          it "Removes a section" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Section, :count).by(-1)
          end

          it "updates the position" do
            subject.call
            expect(Decidim::ParticipatoryDocuments::Annotation.last.position).to eq(1)
          end

          context "when other annotation is not in the same document" do
            let!(:another_section) { create(:participatory_documents_section) }

            it "does not udpate the position" do
              subject.call
              expect(Decidim::ParticipatoryDocuments::Annotation.last.position).to eq(1)
            end
          end
        end
      end
    end
  end
end
