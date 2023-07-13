import PolygonViewer from "src/decidim/participatory_documents/pdf/polygon_viewer";
import SuggestionForm from "src/decidim/participatory_documents/pdf/suggestion_form";
import "src/decidim/participatory_documents/pdf_notifications";
import "src/decidim/participatory_documents/global";

window.currentSuggestionForm = null;
window.InitDocumentManagers = (options) => {
  options.globalSuggestionsButton.addEventListener("click", (evt) => {
    evt.stopPropagation();
    if (window.currentSuggestionForm && !window.currentSuggestionForm.group && window.currentSuggestionForm.div.classList.contains("active")) {
      window.currentSuggestionForm.close();
    } else {
      window.currentSuggestionForm = new SuggestionForm(options.participationLayout, options.documentPath, null);
      window.currentSuggestionForm.fetchGroup();
      window.currentSuggestionForm.open();
    }
  });

  const decidim = document.getElementById("decidim");
  options.exportModal.addEventListener("click", (evt) => {
    evt.stopPropagation();
  });
  options.exportButton.addEventListener("click", (evt) => {
    evt.stopPropagation();
    const uiClose = decidim.querySelector(".close-button");
    uiClose.addEventListener("click", () => decidim.classList.remove("show"), { once: true });
    decidim.addEventListener("click", () => decidim.classList.remove("show"), { once: true });

    decidim.classList.add("show");
  });
  options.exportModal.querySelector(".export-button").addEventListener("click", (evt) => {
    evt.stopPropagation();
    fetch(evt.target.dataset.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.getElementsByName("csrf-token").item(0).content
      },
      credentials: "include"
    }).
      then((response) => {
        if (response.ok) {
          return response.json();
        }
        return response.json().then((json) => { 
          throw new Error(json.message) 
        });
      }).
      then((resp) => {
        // console.log("response ok", resp);
        options.exportModal.querySelector(".content").innerHTML = `<div class="callout success">${resp.message}</div>`;
      }).
      catch((message) => {
        options.exportModal.querySelector(".content").innerHTML = `<div class="callout alert">${message}</div>`;
        // console.error("Error exporting", message);
      });
  });
};

// Call this on an annotation layer to initialize the polygon viewer (public side)
window.InitPolygonViewer = (layer, boxes, options) => {
  let viewer = new PolygonViewer(layer, boxes, { i18n: options.i18n});

  viewer.onBoxClick = (box, evt) => {
    console.log("click on box", box, evt);
    window.currentSuggestionForm = new SuggestionForm(options.participationLayout, options.documentPath, box.section);
    window.currentSuggestionForm.open();
    window.currentSuggestionForm.fetchGroup();
  }

  viewer.onBoxBlur = (box, evt) => {
    console.log("click outside box", box, evt);
    window.currentSuggestionForm.close();
  };

  return viewer;
};
