# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationForm < Decidim::Form
        mimic :annotation

        attribute :annotation_type
        attribute :thickness
        attribute :page_index
        attribute :rotation
        attribute :opacity
        attribute :scale
        attribute :paths, Array
        attribute :color
        attribute :rect
      end
    end
  end
end
