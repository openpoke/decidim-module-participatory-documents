# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module DocumentsHelper
      def box_color_as_rgba(document)
        return "rgba(30, 152, 215, 0.12);" unless document.box_color.present? && document.box_opacity.present?

        document.box_color + (document.box_opacity * 2.55).round.to_s(16).rjust(2, "0")
      end
    end
  end
end
