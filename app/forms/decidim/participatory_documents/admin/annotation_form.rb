# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationForm < Decidim::Form
        mimic :annotation

        attribute :id, Integer
        attribute :rect
        attribute :page_number, Integer
        attribute :section, Integer
      end
    end
  end
end
