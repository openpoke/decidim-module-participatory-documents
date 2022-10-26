# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateDocument  < Rectify::Command
        def initialize(form, document)
          @form = form
          @document = document
          @attached_to = document
        end

        def call
          return broadcast(:invalid) if form.invalid?
          transaction do
            update_document
          end
          broadcast(:ok, document)
        end

        private
        attr_reader :form, :document


        def update_document
          Decidim.traceability.update!(
            document,
            form.current_user,
            title: form.title,
            description: form.description
          )
        end
      end
    end
  end
end
