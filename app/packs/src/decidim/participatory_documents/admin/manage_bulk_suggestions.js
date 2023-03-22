const selectedSuggestionsCount = function() {
  return document.querySelectorAll(".table-list .js-check-all-suggestion:checked").length
}

// const showOtherActionsButtons = function(){
//   document.getElementById("js-other-actions-wrapper").classList.remove("hide");
// }
// const hideOtherActionsButtons = function () {
//   document.getElementById("js-other-actions-wrapper").classList.add("hide");
// }

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


const selectedSuggestionsNotPublishedAnswerCount = function() {
  return document.querySelectorAll(".table-list [data-published-state=false] .js-check-all-suggestion:checked").length;
}

const selectedSugestionsCountUpdate = function() {
  const selectedSuggestions = selectedSuggestionsCount();
  const selectedSuggestionsNotPublishedCount = selectedSuggestionsNotPublishedAnswerCount();
  if (selectedSuggestions === 0) {
    document.getElementById("js-selected-suggestions-count").innerHTML = "";
  } else {
    document.getElementById("js-selected-suggestions-count").innerHTML = selectedSuggestions;
  }

  if (selectedSuggestionsNotPublishedCount > 0) {
    document.querySelector("button[data-action=\"publish-answers\"]").parentElement.classList.remove("hide");
    document.getElementById("js-form-publish-answers-number").innerText = selectedSuggestionsNotPublishedCount;
  } else {
    document.querySelector("button[data-action=\"publish-answers\"]").parentElement.classList.add("hide");
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
      button.addEventListener("click", (evt) => {
        evt.preventDefault();
        let action = evt.target.dataset.action;

        if (action) {
          document.getElementById(`js-${action}-actions`).classList.remove("hide");
          hideBulkActionsButton(true);
          // hideOtherActionsButtons();
        }

      })
    });

    const checkAll = document.getElementById("suggestions_bulk");
    checkAll.addEventListener("change", () => {
      document.querySelectorAll(".js-check-all-suggestion").forEach((suggestion) => {
        suggestion.checked = checkAll.checked;
      });
      document.querySelectorAll(".table-list .js-check-all-suggestion").forEach((suggestion) => {
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
      checkbox.addEventListener("change", (evt) => {
        let suggestionId = evt.target.value;
        let checked = evt.target.checked;

        let selector = ".table-list .js-check-all-suggestion"
        document.getElementById("suggestions_bulk").checked =
                    document.querySelectorAll(`${selector}:checked`).length === document.querySelectorAll(selector).length;

        if (checked) {
          showBulkActionsButton();
          evt.target.closest("tr").classList.add("selected");
        } else {
          hideBulkActionsButton();
          evt.target.closest("tr").classList.remove("selected");
        }

        if (selectedSuggestionsCount() === 0) {
          hideBulkActionsButton();
        }

        console.log(`.js-bulk-action-form .js-suggestion-id-${suggestionId}`);
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
        // showOtherActionsButtons();
      })
    })
  }
});
