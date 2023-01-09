# frozen_string_literal: true
module Decidim
  module ParticipatoryDocuments
    class Suggestion < ApplicationRecord
      include Decidim::Authorable
      include Decidim::Traceable
      include Decidim::Loggable
      belongs_to :zone, class_name: "Decidim::ParticipatoryDocuments::Zone", counter_cache: true

      delegate :organization, to: :zone
      # POSSIBLE_STATES = %w(not_answered evaluating accepted rejected withdrawn).freeze

    end
  end
end
