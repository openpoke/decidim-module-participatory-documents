# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module AdminLog
      # This class holds the logic to present a `Decidim::ParticipatoryDocuments::EvaluationAssignment`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    EvaluationAssignmentPresenter.new(action_log, view_helpers).present
      class EvaluationAssignmentPresenter < Decidim::Log::BasePresenter
        private

        def resource_presenter
          @resource_presenter ||= Decidim::ParticipatoryDocuments::Log::EvaluationAssignmentPresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        def diff_fields_mapping
          {
            evaluator_role_id: "Decidim::ParticipatoryDocuments::AdminLog::ValueTypes::EvaluatorRoleUserPresenter"
          }
        end

        def action_string
          case action
          when "create", "delete"
            "decidim.participatory_documents.admin_log.evaluation_assignment.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.evaluation_assignment.admin_log"
        end

        def diff_actions
          super + %w(create delete)
        end

        def i18n_params
          super.merge(suggestion_title: h.translated_attribute(action_log.extra["suggestion_title"]))
        end
      end
    end
  end
end
