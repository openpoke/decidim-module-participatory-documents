# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UpdateSection do
        subject { described_class.new(form, section.document) }

        let(:section) { create(:participatory_documents_section) }
        let(:uid) { section.uid }
        let(:invalid) { false }
        let(:title) { { en: "Title test Section" } }
        let(:current_user) { section.document.author }

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
            subject.call
            section.reload

            expect(section.title["en"]).to eq(title[:en])
          end
        end
      end
    end
  end
end
