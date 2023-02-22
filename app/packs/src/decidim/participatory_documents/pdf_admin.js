import "src/decidim/participatory_documents/global";
import PolygonEditor from "src/decidim/participatory_documents/polygon_editor";
import PdfStateManager from "src/decidim/participatory_documents/pdf_state_manager";

import "src/decidim/participatory_documents/pdf_notifications";
window.PdfDocStateManager = new PdfStateManager();

// Call this on an annotation layer to initialize the polygon editor (admin side)
window.InitPolygonEditor = function(i18n, layer, boxes) {
  let editor = new PolygonEditor(layer, boxes, { i18n: i18n, stateManager: window.PdfDocStateManager});
  editor.onBoxClick = (box, evt) => {
    window.showInfo("click on box", box, evt);
    window.loadBoxModal(box);
  };
  editor.onBoxChange = (box) => {
    // e.stopPropagation();
    box.setModified();
  };
  editor.onBoxLeave = (box) => {
    // e.stopPropagation();
    if (box.hasChanged()) {
      box.setModified()
    }
  }

  return editor;
};
