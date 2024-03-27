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

  const exportContent = options.exportModal.querySelector(".content");
  const exportCallout = options.exportModal.querySelector(".callout");
  const exportButton = options.exportModal.querySelector(".export-button");
  const closeButton = options.exportModal.querySelector(".close-button");

  options.exportButton.addEventListener("click", (evt) => {
    evt.stopPropagation();
    exportCallout.classList.remove("alert", "success");
    exportCallout.classList.add("hidden");
    exportContent.classList.remove("hidden");
    exportButton.classList.remove("hidden");
    window.Decidim.currentDialogs[options.exportModal.id].open();
  });

  closeButton.addEventListener("click", (evt) => {
    evt.stopPropagation();
    window.Decidim.currentDialogs[options.exportModal.id].close();
  });

  exportButton.addEventListener("click", (evt) => {
    evt.stopPropagation();
    const token = document.getElementsByName("csrf-token");
    fetch(evt.target.dataset.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": token && token[0].content
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
        console.log("response ok", resp);
        exportButton.classList.add("hidden");
        exportContent.classList.add("hidden");
        exportCallout.classList.remove("hidden");
        exportCallout.classList.add("success");
        exportCallout.innerHTML = resp.message;
      }).
      catch((message) => {
        exportButton.classList.add("hidden");
        exportContent.classList.add("hidden");
        exportCallout.classList.remove("hidden");
        exportCallout.classList.add("alert");
        exportCallout.innerHTML = message;
        console.error("Error exporting", message);
      });
  });
};

// Call this on an annotation layer to initialize the polygon viewer (public side)
window.InitPolygonViewer = (layer, boxes, options) => {
  let viewer = new PolygonViewer(layer, boxes, { i18n: options.i18n});

  // prevent hiding the layout due onBoxBlur
  options.participationLayout.addEventListener("click", (evt) => {
    evt.stopPropagation();
  });

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
