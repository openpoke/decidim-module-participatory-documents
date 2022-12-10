# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module DocumentsHelper
        def pdf_manage_button(document)
          if document.blank? && allowed_to?(:create, :participatory_document)
            new_pdf_btn
          elsif document.file.attached? && allowed_to?(:update, :participatory_document)
            edit_pdf_btn
          else
            edit_document_btn
          end
        end

        private

        def btn_icon
          icon("document", class: "icon--document icon icon icon-document mr-xs", aria_label: btn_title, role: "img")
        end

        def btn_title
          return t("actions.new", scope: "decidim.participatory_documents") if document.blank?

          if document.file.attached?
            t("actions.edit_pdf", scope: "decidim.participatory_documents")
          else
            t("actions.edit_document", scope: "decidim.participatory_documents")
          end
        end

        def new_pdf_btn
          content_tag(:div, class: "flex--cc flex-gap--1") do
            content_tag(:a, title: btn_title, href: new_document_path, class: "button button--simple") do
              btn_icon + content_tag(:span, btn_title)
            end
          end
        end

        def edit_pdf_btn
          content_tag(:div, class: "flex--cc flex-gap--1") do
            content_tag(:a, title: btn_title, href: edit_pdf_documents_path(id: document.id), class: "button button--simple") do
              btn_icon + content_tag(:span, btn_title)
            end
          end
        end

        def edit_document_btn
          content_tag(:div, class: "flex--cc flex-gap--1") do
            content_tag(:a, title: btn_title, href: edit_document_path(id: document.id), class: "button button--simple") do
              btn_icon + content_tag(:span, btn_title)
            end
          end
        end
      end
    end
  end
end
