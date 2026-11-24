# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::Engine do
  it_behaves_like "clean engine"

  it "keeps the javascript format of Rails" do
    expect(Mime::Type.lookup("text/javascript").symbol).to eq(:js)
  end

  it "lets Rack serve the .mjs files as javascript" do
    expect(Rack::Mime.mime_type(".mjs")).to eq("text/javascript")
  end
end
