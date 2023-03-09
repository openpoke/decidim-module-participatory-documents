import "src/decidim/participatory_documents/global";
import "src/decidim/participatory_documents/pdf_notifications";
import PolygonEditor from "src/decidim/participatory_documents/pdf/polygon_editor";
import PdfStateManager from "src/decidim/participatory_documents/pdf/pdf_state_manager";
import PdfModalManager from "src/decidim/participatory_documents/pdf/pdf_modal_manager";

// Call this on an annotation layer to initialize the polygon editor (admin side)
window.InitPolygonEditor = function(layer, boxes, options) {
  options.saveButton = document.getElementById("DecidimPDSaveButton");
  options.csrfToken = document.getElementsByName("csrf-token")[0].content;
  options.showInfo = window.showInfo;
  options.showAlert = window.showAlert;
  
  window.PdfDocStateManager = new PdfStateManager(options);
  // show message when saving
  window.PdfDocStateManager.onSave = () => {
    window.showInfo(options.i18n.allSaved);
  };
  
  window.PdfModalManager = new PdfModalManager(options);
  let editor = new PolygonEditor(layer, boxes, { i18n: options.i18n });

  // remove box from the global state manager if edited though the modal
  window.PdfModalManager.onSave = (box) => {
    window.PdfDocStateManager.remove(box);
  };
  
  // Open the global box modal settings when a box is clicked
  editor.onBoxClick = (box) => {
    window.PdfModalManager.loadBoxModal(box);
  };

  // update the global state manager when a box is edited or destroyed using the polygon editor (mouse interaction)
  editor.onBoxChange = (box) => {
    window.PdfDocStateManager.add(box);
  };
  editor.onBoxDestroy = (box) => {
    window.PdfDocStateManager.remove(box);
  };

  return editor;
};
