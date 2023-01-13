# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe CreateSection do
        subject { described_class.new(form, document) }

        let(:document) { create(:participatory_documents_document) }
        let(:uid) { "RandomUUID" }

        let(:current_user) { document.author }

        let(:title) { { en: "Title test Section" } }
        let(:invalid) { false }
        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            uid: uid,
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
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Section, :count).by(1)
          end
        end
      end
    end
  end
end
