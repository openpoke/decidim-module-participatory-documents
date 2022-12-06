# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateAnnotation < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              create_annotation
            end
            broadcast(:ok, annotation)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :annotation

        def create_annotation
          @annotation = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Annotation,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            page_number: form.page_number,
            rect: form.rect,
            uid: form.id
          }.merge(zone: zone)
        end

        def zone
          @zone ||= Decidim::ParticipatoryDocuments::Zone.where(document: document, uid: form.group).first_or_create
        end
      end
    end
  end
end
