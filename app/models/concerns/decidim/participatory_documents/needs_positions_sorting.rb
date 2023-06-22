# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module NeedsPositionsSorting
      extend ActiveSupport::Concern

      included do
        after_commit :update_positions

        private

        # rubocop:disable Rails/SkipsModelValidations
        def update_positions
          boxes = document.annotations.reload.sort do |a, b|
            if a.page_number == b.page_number
              if a.rect["top"].to_i == b.rect["top"].to_i
                a.rect["left"].to_i <=> b.rect["left"].to_i
              else
                a.position <=> b.position
              end
            else
              a.page_number <=> b.page_number
            end
          end

          section_number = 0
          all_sections = {}
          boxes.each_with_index do |box, index|
            box.update_column(:position, index + 1)
            if all_sections[box.section_id]
              box.section.update_column(:position, all_sections[box.section_id])
            else
              section_number += 1
              box.section.update_column(:position, section_number)
            end
            all_sections[box.section_id] = section_number
          end
        end
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
