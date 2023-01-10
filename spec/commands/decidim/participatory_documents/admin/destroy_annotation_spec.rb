# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DestroyAnnotation do
        let!(:annotation) { create(:participatory_documents_annotation) }
        subject { described_class.new(form, annotation.section.document) }
        let(:user) { annotation.section.document.author }
        let(:invalid) { false }

        let(:form) do
          double(
            invalid?: invalid,
            id: annotation.uid,
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
          it "Removes a annotation" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Annotation, :count).by(-1)
          end
        end
      end
    end
  end
end
