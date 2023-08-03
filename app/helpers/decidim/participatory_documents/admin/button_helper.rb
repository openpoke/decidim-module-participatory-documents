# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module ButtonHelper
        def button_builder(btn_title, icon: "document")
          btn_icon(icon, btn_title) + content_tag(:span, btn_title)
        end

        def btn_icon(icon, label)
          icon(icon, class: "icon--document icon icon icon-document mr-xs", aria_label: label, role: "img")
        end
      end
    end
  end
end
