# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::Engine do
  it_behaves_like "clean engine"

  it "lets Rack serve the .mjs files as javascript" do
    expect(Rack::Mime.mime_type(".mjs")).to eq("text/javascript")
  end
end
