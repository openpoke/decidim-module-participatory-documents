# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::CreateSuggestion do
  subject { described_class.new(form, section) }

  let(:organization) { component.organization }
  let(:component) { create(:participatory_documents_component) }
  let(:document) { create :participatory_documents_document, component: component }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:section) { create(:participatory_documents_section, document: document) }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      body: body,
      file: nil
    )
  end
  let(:invalid) { false }
  let(:body) { "<img onerror=alert(document.domain) src=x>Text" }

  context "when the form is invalid" do
    let(:invalid) { true }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "creates a suggestion" do
      expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Suggestion, :count).by(1)
    end

    it "sanitizes the body content" do
      subject.call
      last_suggestion = Decidim::ParticipatoryDocuments::Suggestion.last
      expect(last_suggestion.body.values.first).to eq("Text")
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end
  end
end
