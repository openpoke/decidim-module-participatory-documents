# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module DocumentsHelper
      include Decidim::ParticipatoryDocuments::Admin::ButtonHelper

      def back_edit_pdf_btn
        btn_title = t("actions.back_edit", scope: "decidim.participatory_documents")

        content_tag(:a,
                    title: btn_title,
                    href: Decidim::EngineRouter.admin_proxy(document.component).edit_pdf_documents_path(id: document.id),
                    class: "button button__sm button__warning") do
          button_builder(btn_title, icon: "stack-line")
        end
      end

      def finish_publish_btn
        btn_title = t("actions.finish_publishing", scope: "decidim.participatory_documents")

        link_to(
          Decidim::EngineRouter.admin_proxy(document.component).publish_document_path(document),
          method: :put,
          data: { confirm: t("actions.confirm", scope: "decidim.participatory_documents") },
          class: "button button__sm button__success"
        ) do
          button_builder(btn_title, icon: "checkbox-multiple-line")
        end
      end

      def preview_mode?
        return false if current_user.blank?

        admin_allowed_to?(:manage, :component, component: current_component, current_participatory_space:) &&
          admin_allowed_to?(:update, :participatory_document, document:)
      end
    end
  end
end
