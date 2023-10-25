# frozen_string_literal: true

require "i18n/tasks"

describe "document component", type: :system do
  let!(:document) { create(:participatory_documents_document) }
  let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:another_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:component) { document.component }
  let(:manifest) { component.manifest.export_manifests.find { |manifest| manifest.name == :suggestions } }
  let(:collection) { manifest.collection.call(component, user, context) }
  let(:context) { nil }
  let(:user) { nil }

  it "export valuators and different users"	do
    expect(collection).to include(suggestion)
    expect(collection).to include(another_suggestion)
    expect(collection.map(&:author).uniq.count).to eq(2)
  end

  context "when user is specified" do
    let(:user) { suggestion.author }
    let(:context) { :my_suggestions }

    it "export only valuators from the user" do
      expect(collection).to include(suggestion)
      expect(collection).not_to include(another_suggestion)
    end
  end
end
