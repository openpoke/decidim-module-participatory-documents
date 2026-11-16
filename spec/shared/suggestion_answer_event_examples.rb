# frozen_string_literal: true

shared_examples "an answered suggestion event" do
  let(:event_name) { "decidim.events.participatory_documents.suggestion_answered" }
  let(:email_subject) { "A suggestion you have submitted has been answered by an administrator" }
  let(:email_intro) do
    "A suggestion you submitted on \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document has been answered by an administrator. You can read the answer in this page:"
  end
  let(:email_outro) { "You have received this notification because you have submitted a suggestion for \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document." }
  let(:notification_title) { "A suggestion you submitted on \"<a href=\"#{resource_path}\">#{resource_title}</a>\" document has been answered by an administrator" }

  include_context "when a simple event" do
    let(:user_role) { :affected_user }
    let(:resource_path) { main_component_path(document.component) }
    let(:resource_title) { decidim_sanitize_translated(document.title) }
  end

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  describe "resource_text" do
    it "shows the suggestion answer" do
      expect(subject.resource_text).to eq translated(resource.answer)
    end
  end

  describe "resource_title" do
    before { document.update!(title: { en: "<script>alert(1)</script>Rules" }) }

    it "sanitizes the document title" do
      expect(subject.resource_title).to include("Rules")
      expect(subject.resource_title).not_to include("<script>")
    end
  end
end

shared_examples "a suggestion answer event" do |state|
  context "when the suggestion is added to a document" do
    let(:document) { create(:participatory_documents_document) }
    let(:resource) { create(:participatory_documents_suggestion, state, :with_answer, suggestable: document) }

    it_behaves_like "an answered suggestion event"
  end

  context "when the suggestion is added to a section" do
    let(:section) { create(:participatory_documents_section) }
    let(:document) { section.document }
    let(:resource) { create(:participatory_documents_suggestion, state, :with_answer, suggestable: section) }

    it_behaves_like "an answered suggestion event"
  end
end
