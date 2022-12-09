# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module DocumentsHelper
        def pdf_manage_button(document)
          title = document.present? && document.file.attached? ?
                    t("actions.edit_pdf", scope: "decidim.participatory_documents") :
                    t("actions.new", scope: "decidim.participatory_documents")

          href = document.present? && document.file.attached? ? edit_pdf_documents_path(id: document.id) : new_document_path

          content_icon = icon("document", class: "icon--document icon icon icon-document mr-xs", aria_label: title, role: "img")

          content_tag(:div, class: "flex--cc flex-gap--1") do
            content_tag(:a, title: title, href: href, class: "button button--simple") do
              content_icon + content_tag(:span, title)
            end
          end
        end
      end
    end
  end
end
