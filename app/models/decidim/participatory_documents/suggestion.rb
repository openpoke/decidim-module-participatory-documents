# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Suggestion < ApplicationRecord
      include Decidim::Authorable

      delegate :organization, to: :suggestable
      belongs_to :suggestable, polymorphic: true
    end
  end
end
