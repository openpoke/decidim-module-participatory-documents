# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationForm < Decidim::Form
        mimic :annotation

        attribute :id
        attribute :rect
        attribute :page_number
        attribute :group
      end
    end
  end
end
