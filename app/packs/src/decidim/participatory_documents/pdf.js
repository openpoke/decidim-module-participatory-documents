import PolygonViewer from "src/decidim/participatory_documents/pdf/polygon_viewer";
import SuggestionForm from "src/decidim/participatory_documents/pdf/suggestion_form";
import "src/decidim/participatory_documents/pdf_notifications";
import "src/decidim/participatory_documents/global";

window.InitDocumentManagers = function(options) {
  options.globalSuggestionsButton.addEventListener("click", () => {
    (new SuggestionForm(options.documentPath, null)).fetchGroup();
  });
};

// Call this on an annotation layer to initialize the polygon viewer (public side)
window.InitPolygonViewer = function(layer, boxes, options) {
  let viewer = new PolygonViewer(layer, boxes, { i18n: options.i18n});

  viewer.onBoxClick = function(box, evt) {
    console.log("click on box", box, evt);
    options.participationLayout.classList.add("active");
    (new SuggestionForm(options.documentPath, box.section)).fetchGroup();
  }

  viewer.onBoxBlur = (box, evt) => {
    console.log("click ouside box", box, evt);
    options.participationLayout.classList.remove("active");
  };

  return viewer;
};
