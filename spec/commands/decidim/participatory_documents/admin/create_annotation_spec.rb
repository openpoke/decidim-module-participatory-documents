# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe CreateAnnotation do
        subject { described_class.new(form, document) }

        let(:document) { create(:participatory_documents_document) }
        let(:invalid) { false }
        let(:current_user) { document.author }

        let(:form) do
          double(
            invalid?: invalid,
            page_number: 1,
            rect: [50, 50, 100, 100],
            id: "annotationid",
            group: "groupid",
            current_user: current_user
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "creates a section" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Annotation, :count).by(1)
          end
        end
      end
    end
  end
end
