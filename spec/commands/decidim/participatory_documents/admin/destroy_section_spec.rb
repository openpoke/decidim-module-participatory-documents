# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DestroySection do
        subject { described_class.new(form, section.document) }

        let(:section) { create(:participatory_documents_section) }
        let!(:annotations) { create_list(:participatory_documents_annotation, 2, section: section) }
        let(:uid) { section.uid }

        let(:current_user) { section.document.author }
        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            uid: uid,
            current_user: current_user
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            # expect { subject.call }.to broadcast(:invalid)
            pending "There are no existance constraints yet"
            raise "Pending"
          end
        end

        context "when valid" do
          it "Removes a section" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Section, :count).by(-1)
          end

          it "Removes all the annotations" do
            expect(Decidim::ParticipatoryDocuments::Annotation.count).to eq(2)
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Annotation, :count).by(-2)
            expect(Decidim::ParticipatoryDocuments::Annotation.count).to eq(0)
          end
        end
      end
    end
  end
end
