# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::AcceptedSuggestionEvent do
  let(:document) { create :participatory_documents_document }
  let(:resource) { create(:participatory_documents_suggestion, :with_answer, suggestable: document) }

  let(:event_name) { "decidim.events.participatory_documents.suggestion_accepted" }
  let(:resource_path) { main_component_path(document.component) }
  let(:resource_title) { translated(document.title["en"]) }

  include_context "when a simple event" do
    let(:resource_title) { translated(document.title["en"]) }
    let(:resource_path) { main_component_path(document.component) }
  end

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A suggestion you're following has been accepted")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("A suggestion for \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document has been accepted. You can read the answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"<a href=\"#{resource_path}\">#{resource_title}</a>\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("A suggestion for <a href=\"#{resource_path}\">#{resource_title}</a> document has been accepted")
    end
  end

  describe "resource_text" do
    it "shows the proposal answer" do
      expect(subject.resource_text).to eq translated(resource.answer)
    end
  end
end
