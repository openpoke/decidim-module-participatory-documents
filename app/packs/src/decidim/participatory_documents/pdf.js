import PolygonViewer from "src/decidim/participatory_documents/pdf/polygon_viewer";
import PdfStateManager from "src/decidim/participatory_documents/pdf/pdf_state_manager";
import "src/decidim/participatory_documents/pdf_notifications";
import "src/decidim/participatory_documents/global";

// state manager
window.PdfDocStateManager = new PdfStateManager();

// Call this on an annotation layer to initialize the polygon viewer (public side)
window.InitPolygonViewer = function(i18n, layer, boxes) {
  let viewer = new PolygonViewer(layer, boxes, { i18n: i18n, stateManager: window.PdfDocStateManager});
  viewer.onBoxClick = (box, evt) => {
    console.log("click on box", box, evt);
    console.log("show the participation modal");
    let div = document.getElementById("participation-modal");
    div.innerHTML = `Clicked ${box.id}. Should allow comments for group ${box.section}`;
    div.classList.add("active");
  };

  viewer.onBoxBlur = (box, evt) => {
    console.log("click ouside box", box, evt);
    console.log("hide the participation modal");
    let div = document.getElementById("participation-modal");
    div.classList.remove("active");
  };

  return viewer;
};
