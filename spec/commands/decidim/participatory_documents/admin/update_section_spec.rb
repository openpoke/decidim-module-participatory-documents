# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UpdateSection do
        subject { described_class.new(form, section.document) }

        let(:section) { create(:participatory_documents_section) }
        let(:id) { section.id }
        let(:invalid) { false }
        let(:title) { { en: "Title test Section" } }
        let(:current_user) { section.document.author }

        let(:form) { double(invalid?: invalid, title:, id:, current_user:) }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "updates the section" do
            subject.call
            section.reload

            expect(section.title["en"]).to eq(title[:en])
          end
        end

        context "when the section has no title and only one language is changed" do
          let(:section) { create(:participatory_documents_section, title: nil, position: 3) }
          let(:title) { section.title.merge("en" => "Title test Section") }

          it "stores only the changed language" do
            subject.call

            expect(section.reload[:title]).to eq("en" => "Title test Section")
          end
        end
      end
    end
  end
end
