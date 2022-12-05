import PolygonEditor from "src/decidim/participatory_documents/polygon_editor";
import "src/decidim/participatory_documents/pdf_notifications";

// TODO: load configuration from server using ajax
// This probably needs refactoring to its own class
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

// Call this on an annotation layer to initialize the polygon editor (admin side)
window.InitPolygonEditor = function(layer, boxes) {
  var editor = new PolygonEditor(layer, boxes);
  editor.onBoxClick = (box, e) => {
    showInfo("click on box", box, e);
    loadBoxModal(box);
  };
  editor.onBoxChange = (box, e) => {
    showAlert("box changed, should we save to the database now?", box, e, box.getInfo());
  };
  // editor.onBoxDestroy = (box, e) => {
  //   showAlert("box destroyed", box, e);
  // };
};
