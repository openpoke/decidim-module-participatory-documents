# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Annotation < ApplicationRecord
      belongs_to :zone, class_name: "Decidim::ParticipatoryDocuments::Zone"
    end
  end
end
