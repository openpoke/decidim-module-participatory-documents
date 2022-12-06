import PolygonEditor from "src/decidim/participatory_documents/polygon_editor";
import "src/decidim/participatory_documents/pdf_notifications";


window.sendRequest = function(url, action, box, message)
{
  let data = box.getInfo();
  data.page_number = PDFViewerApplication.pdfViewer.currentPageNumber;
  const csrfToken = document.getElementsByName("csrf-token")[0].content;


   $.ajax({
      url: url,
      type: action,
      data: data,
      headers: { "X-CSRF-Token": csrfToken },
   })
   .done(function() {
      showInfo(message);
   })
   .fail(function() {
      box.destroy();
      showAlert(I18n.operationFailed);
   })
   .always(function() {});
}

window.removeBox = function(box){
  sendRequest(AnnotationsRootPath + "/" + box.id, "DELETE", box, I18n.removed);
}

window.createBox = function(box){
  sendRequest(AnnotationsRootPath, "POST", box, I18n.created);
}

window.updateBox = function(box){
  sendRequest(AnnotationsRootPath + "/" + box.id, "PUT", box, I18n.updated);
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
    showInfo("click on box", box, e);
    loadBoxModal(box);
  };
  editor.onBoxChange = (box, e) => {
    showAlert("box changed, should we save to the database now?", box, e, box.getInfo());
    updateBox(box);
  };
  // editor.onBoxDestroy = (box, e) => {
  //   showAlert("box destroyed", box, e);
  // };
};
