import SuggestionUploadModal from "src/decidim/participatory_documents/upload_modal";

/** @type {SuggestionUploadModal | null} */
let suggestionModalInstance = null;

/**
 * Initializes the upload modal for suggestions.
 * Reconnects MutationObserver after each form submit.
 *
 * @returns {void}
 */
const initializeSuggestionModal = () => {
  if (suggestionModalInstance?.observer) {
    suggestionModalInstance.observer.disconnect();
  }

  suggestionModalInstance = new SuggestionUploadModal();
  window.SuggestionUploadModal = suggestionModalInstance;
};

document.addEventListener("DOMContentLoaded", () => {
  initializeSuggestionModal();

  document.body.addEventListener("submit", (event) => {
    const form = event.target.closest("#new_suggestion_");
    if (form) {
      setTimeout(initializeSuggestionModal, 100);
    }
  });
});
