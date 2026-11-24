# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Suggestion, type: :helper do
      describe "admin log entries" do
        subject { action_log.log_presenter_class_for(:admin_log).new(action_log, helper).present }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:participatory_documents_component, participatory_space:) }
        let(:document) { create(:participatory_documents_document, component:) }
        let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document, body: { en: "Please widen the bike lane" }) }
        let(:action_log) { create(:action_log, user:, action:, resource: suggestion, component:, participatory_space:) }

        before do
          helper.extend(Decidim::ApplicationHelper)
          helper.extend(Decidim::TranslationsHelper)
        end

        %w(create answer publish_answer).each do |logged_action|
          context "when the logged action is #{logged_action}" do
            let(:action) { logged_action }

            it "renders the entry with the suggestion text" do
              expect(subject).to include("Please widen the bike lane")
            end
          end
        end
      end
    end
  end
end
