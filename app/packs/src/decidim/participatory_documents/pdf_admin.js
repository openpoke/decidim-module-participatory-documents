import "src/decidim/participatory_documents/global";
import "src/decidim/participatory_documents/pdf_notifications";
import PolygonEditor from "src/decidim/participatory_documents/pdf/polygon_editor";
import PdfStateManager from "src/decidim/participatory_documents/pdf/pdf_state_manager";
import PdfModalManager from "src/decidim/participatory_documents/pdf/pdf_modal_manager";


window.InitDocumentManagers = function(options) {
  window.PdfDocStateManager = new PdfStateManager(options);
  // show message when saving
  window.PdfDocStateManager.onSave = () => {
    window.showInfo(options.i18n.allSaved);
  };
  window.PdfDocStateManager.onError = (errors) => {
    window.showAlert(options.i18n.errorsSaving);
    console.error("State Manager Errors:", errors);
  };

  window.PdfModalManager = new PdfModalManager(options);

  // remove box from the global state manager if edited though the modal
  window.PdfModalManager.onSave = (box) => {
    window.PdfDocStateManager.remove(box);
    window.showInfo(options.i18n.created);
  };
  window.PdfModalManager.onDestroy = (box) => {
    window.PdfDocStateManager.remove(box);
    window.showInfo(options.i18n.removed);
  };
  window.PdfModalManager.onError = (box, error) => {
    window.showAlert(options.i18n.operationFailed);
    console.error("Modal Manager Error:", error);
  };
};

// Call this on an annotation layer to initialize the polygon editor (admin side)
window.InitPolygonEditor = function(layer, boxes, options) {    
  let editor = new PolygonEditor(layer, boxes, { i18n: options.i18n });
  // Open the global box modal settings when a box is clicked
  editor.onBoxClick = (box) => {
    console.log("BOX click", box)
    if (box.isPersisted()) {
      window.PdfModalManager.loadBoxModal(box);
    } else {
      window.showAlert(options.i18n.needsSaving);
    }
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
