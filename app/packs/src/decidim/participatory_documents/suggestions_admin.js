const selectedSuggestionsCount = function() {
  return document.querySelectorAll(".table-list .js-check-all-suggestion:checked").length
}

const showBulkActionsButton = function() {
  if (selectedSuggestionsCount() > 0) {
    document.getElementById("js-bulk-actions-button").classList.remove("hide");
  }
}
const hideBulkActionsButton = function(force = false) {
  if (selectedSuggestionsCount() === 0 || force === true) {
    document.getElementById("js-bulk-actions-button").classList.add("hide");
    document.getElementById("js-bulk-actions-dropdown").classList.remove("is-open");
  }
}

const selectedSugestionsCountUpdate = function() {
  const selectedSuggestions = selectedSuggestionsCount();
  if (selectedSuggestions === 0) {
    document.getElementById("js-selected-suggestions-count").innerHTML = "";
  } else {
    document.getElementById("js-selected-suggestions-count").innerHTML = selectedSuggestions;
  }
}

const hideBulkActionForms = function() {
  document.querySelectorAll(".js-bulk-action-form").forEach((form) => {
    form.classList.add("hide");
  });
}
window.showBulkActionsButton = showBulkActionsButton
window.hideBulkActionsButton = hideBulkActionsButton
window.selectedSuggestionsCount = selectedSuggestionsCount
window.selectedSugestionsCountUpdate = selectedSugestionsCountUpdate
window.hideBulkActionForms = hideBulkActionForms

window.addEventListener("load", () => {

  if (document.querySelectorAll(".js-bulk-action-form").length) {
    hideBulkActionForms();
    document.getElementById("js-bulk-actions-button").classList.add("hide");
    document.querySelectorAll("#js-bulk-actions-dropdown ul li button").forEach((button) => {
      button.addEventListener("click", (e) => {
        e.preventDefault();
        let action = e.target.dataset.action;

        if (action) {
          document.getElementById(`js-${action}-actions`).classList.remove("hide");
          hideBulkActionsButton(true);
        }

      })
    });

    const checkAll = document.getElementById("js-check-all");
    checkAll.addEventListener("change", () => {
      document.querySelectorAll(".table-list .js-check-all-suggestion").forEach((suggestion) => {
        console.log(suggestion);
        suggestion.checked = checkAll.checked;
        suggestion.closest("tr").classList.toggle("selected");
      });

      if (checkAll.checked) {
        showBulkActionsButton();
      } else {
        hideBulkActionsButton();
      }

      selectedSugestionsCountUpdate();
    });

    document.querySelectorAll(".js-check-all-suggestion").forEach((checkbox) => {
      checkbox.addEventListener("change", (e) => {
        let suggestionId = e.target.value;
        let checked = e.target.checked;

        let selector = ".table-list .js-check-all-suggestion"
        document.getElementById("js-check-all").checked =
                    document.querySelectorAll(`${selector}:checked`).length === document.querySelectorAll(selector).length;

        if (checked) {
          showBulkActionsButton();
          e.target.closest("tr").classList.add("selected");
        } else {
          hideBulkActionsButton();
          e.target.closest("tr").classList.remove("selected");
        }

        if (selectedSuggestionsCount() === 0) {
          hideBulkActionsButton();
        }

        document.querySelectorAll(`.js-bulk-action-form .js-suggestion-id-${suggestionId}`).forEach((element) => {
          element.checked = checked;
        })

        selectedSugestionsCountUpdate();
      });
    });

    document.querySelectorAll(".js-cancel-bulk-action").forEach((cancel) => {
      cancel.addEventListener("click", () => {
        hideBulkActionForms()
        showBulkActionsButton();
      })
    })
  }
});
