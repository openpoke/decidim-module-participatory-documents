import PolygonEditor from "src/decidim/participatory_documents/polygon_editor";
import PdfStateManager from "src/decidim/participatory_documents/pdf_state_manager";

import "src/decidim/participatory_documents/pdf_notifications";
window.PdfDocStateManager = new PdfStateManager();


window.sendRequest = function(url, action, box, page, message)
{
  let data = box.getInfo();
  data.page_number = page;
  $.ajax({
    url: url,
    type: action,
    data: data,
  })
  .done(function() {
    box.setInfo();
    showInfo(message);
  })
  .fail(function() {
    box.destroy();
    showAlert(I18n.operationFailed);
  })
  .always(function() {});
}
//
//window.removeBox = function(box){
//  sendRequest(AnnotationsRootPath + "/" + box.id, "DELETE", box, I18n.removed);
//}

window.createBox = function(box, page){
  sendRequest(AnnotationsRootPath, "POST", box, page, I18n.created);
}

window.updateBox = function(box, page){
  sendRequest(AnnotationsRootPath + "/" + box.id, "PUT", box, page, I18n.updated);
}

// TODO: load configuration from server using ajax
// This probably needs refactoring to its own class
/*
window.loadBoxModal = function(box) {

console.log("box,box",  box);
    const decidim = document.getElementById("decidim")
    const close = document.getElementById("editor-modal-close");
    const title = document.getElementById("editor-modal-title");
    const content = document.getElementById("editor-modal-content");
    const save = document.getElementById("editor-modal-save");
    const remove = document.getElementById("editor-modal-remove");

    title.innerHTML = `Edit box ${box.id}, group ${box.group}`;

    decidim.classList.add("show");

    close.addEventListener("click", (e) => {
      e.stopPropagation();
      decidim.classList.remove("show");
    }, { once: true });

    save.addEventListener("click", (e) => {
      e.stopPropagation();
      showInfo("Please, save me to the database for the group", box.group);
      decidim.classList.remove("show");
    }, { once: true });

    remove.addEventListener("click", (e) => {
      e.stopPropagation();
      showAlert("Please, remove me (if allowed) from the database");
      box.destroy();
      decidim.classList.remove("show");
    }, { once: true });
};
*/
// Call this on an annotation layer to initialize the polygon editor (admin side)
window.InitPolygonEditor = function(layer, boxes) {
  var editor = new PolygonEditor(layer, boxes);
  editor.onBoxClick = (box, e) => {
      console.log(box.hasChanged());

    showInfo("click on box", box, e);
    loadBoxModal(box);
  };
  editor.onBoxChange = (box, e) => {
//    console.log(box.hasChanged());
//    showAlert("box changed, should we save to the database now?", box, e, box.getInfo());
//    updateBox(box, PDFViewerApplication.pdfViewer.currentPageNumber);
//    if (box.hasChanged()){
      PdfDocStateManager.setModifiedState(box);
//    }
  };
  // editor.onBoxDestroy = (box, e) => {
  //   showAlert("box destroyed", box, e);
  // };
  editor.onBoxBlur = (box, e) => {
     console.log(box);
     console.log("BLUR");
  }
//  editor.onBoxEnter = (box, e) => {
//    console.log(box);
//     console.log("BOX ENTER");
//  }
  editor.onBoxLeave = (box, e) => {
    if (box.hasChanged()){
      PdfDocStateManager.setModifiedState(box);
    }
  }
  editor.onBoxDestroy = (box, e) => {
  console.log(box.hasChanged());
    console.log(box);
     console.log("onBoxDestroy");
  }

  return editor;
};
