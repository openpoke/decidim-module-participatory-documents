# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe PublishDocument do
        subject { described_class.new(document) }

        let(:document) { create(:participatory_documents_document) }

        describe "call" do
          it "broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "updates the document's final_publish attribute to true" do
            subject.call
            expect(document.reload).to be_published
          end
        end
      end
    end
  end
end
