import PolygonViewer from "src/decidim/participatory_documents/polygon_viewer";
import "src/decidim/participatory_documents/pdf_notifications";

// Call this on an annotation layer to initialize the polygon viewer (public side)
window.InitPolygonViewer = function(layer, boxes) {
  var viewer = new PolygonViewer(layer, boxes);
  viewer.onBoxClick = (box, e) => {
    console.log("click on box", box, e);
    console.log("show the participation modal");
    let div = document.getElementById("participation-modal");
    div.innerHTML = `Clicked ${box.id}. Should allow comments for group ${box.group}`;
    div.classList.add("active");
  };

  viewer.onBoxBlur = (box, e) => {
    console.log("click ouside box", box, e);
    console.log("hide the participation modal");
    let div = document.getElementById("participation-modal");
    div.classList.remove("active");
  };
};
