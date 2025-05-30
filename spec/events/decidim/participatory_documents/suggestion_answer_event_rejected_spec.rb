# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::SuggestionAnswerEvent do
  shared_examples "sends the rejected suggestion notification" do
    let(:event_name) { "decidim.events.participatory_documents.suggestion_answered" }

    let(:resource_path) { main_component_path(document.component) }
    let(:resource_title) { translated(document.title["en"]) }

    include_context "when a simple event" do
      let(:user_role) { :affected_user }
      let(:resource_title) { translated(document.title["en"]) }
      let(:resource_path) { main_component_path(document.component) }
    end
    it_behaves_like "a simple event"

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("A suggestion you have submitted has been answered by an administrator")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq("A suggestion you submitted on \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document has been answered by an administrator. You can read the answer in this page:")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq("You have received this notification because you have submitted a suggestion for \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document.")
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include("A suggestion you submitted on \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document has been answered by an administrator")
      end
    end

    describe "resource_text" do
      it "shows the proposal answer" do
        expect(subject.resource_text).to eq translated(resource.answer)
      end
    end
  end

  context "when suggestion is added to a document" do
    let(:document) { create(:participatory_documents_document) }
    let(:resource) { create(:participatory_documents_suggestion, :rejected, :with_answer, suggestable: document) }

    it_behaves_like "sends the rejected suggestion notification"
  end

  context "when suggestion is added to a section" do
    let(:document) { suggestion.document }
    let(:suggestion) { create(:participatory_documents_section) }
    let(:resource) { create(:participatory_documents_suggestion, :rejected, :with_answer, suggestable: suggestion) }

    it_behaves_like "sends the rejected suggestion notification"
  end
end
