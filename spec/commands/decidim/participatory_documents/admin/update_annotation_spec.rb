# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UpdateOrCreateAnnotation do
        subject { described_class.new(form, document) }

        let!(:annotation) { create(:participatory_documents_annotation) }
        let(:document) { annotation.section.document }
        let(:invalid) { false }
        let(:current_user) { document.author }
        let(:rect) { [0, 50, 100, 100] }

        let(:form) do
          double(
            invalid?: invalid,
            page_number: 1,
            rect: rect,
            id: annotation.id,
            section: annotation.section.id,
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
            expect(annotation.rect).not_to eq(rect)
            subject.call
            annotation.reload
            expect(annotation.rect).to eq(rect)
          end
        end
      end
    end
  end
end
