# frozen_string_literal: true

describe Decidim::ParticipatoryDocuments::Admin::SuggestionHelper, type: :helper do
  let(:component) { create :participatory_documents_component }
  let(:document) { create(:participatory_documents_document, component: component) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

  describe "#suggestion_content" do
    it "returns the suggestion body if present" do
      allow(suggestion).to receive(:attachment).and_return(nil)

      expect(helper.suggestion_content(suggestion)[:text]).to include(suggestion.body["en"])
      expect(helper.suggestion_content(suggestion)[:file_link]).to be_nil
    end

    it "returns '(no text)' and file link if suggestion body is blank and file attached" do
      allow(suggestion).to receive(:body).and_return({ "en" => "" })
      suggestion.file.attach(file)

      expect(helper.suggestion_content(suggestion)[:text]).to eq("(no text)")
      expect(helper.suggestion_content(suggestion)[:file_link]).to include("download Exampledocument.pdf")
    end

    it "returns the suggestion body and file link" do
      suggestion.file.attach(file)

      expect(helper.suggestion_content(suggestion)[:text]).to include(suggestion.body["en"])
      expect(helper.suggestion_content(suggestion)[:file_link]).to include("download Exampledocument.pdf")
    end
  end
end
