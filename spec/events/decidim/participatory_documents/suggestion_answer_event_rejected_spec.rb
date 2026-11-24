# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::SuggestionAnswerEvent do
  it_behaves_like "a suggestion answer event", :rejected
end
