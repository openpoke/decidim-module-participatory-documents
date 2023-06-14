# frozen_string_literal: true

describe Decidim::ParticipatoryDocuments::Admin::SuggestionHelper, type: :helper do
  let(:component) { create :participatory_documents_component }
  let(:document) { create(:participatory_documents_document, component: component) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

  describe "#suggestion_content" do
    it "returns the suggestion body if present" do
      allow(suggestion).to receive(:attachment).and_return(nil)

      expect(helper.suggestion_content(suggestion)).to include(suggestion.body["en"])
      expect(helper.suggestion_content(suggestion)).not_to include("Download")
    end

    it "returns '(no text)' and file link if suggestion body is blank and file attached" do
      allow(suggestion).to receive(:body).and_return({ "en" => "" })
      suggestion.file.attach(file)

      expect(helper.suggestion_content(suggestion)).to have_selector("span.muted", text: "(no text)")
      expect(helper.suggestion_content(suggestion)).to have_selector("a[href*='Exampledocument.pdf']", text: "Download")
    end

    it "returns the suggestion body and file link" do
      suggestion.file.attach(file)

      expect(helper.suggestion_content(suggestion)).to include(suggestion.body["en"])
      expect(helper.suggestion_content(suggestion)).to include("Download")
    end
  end
end
