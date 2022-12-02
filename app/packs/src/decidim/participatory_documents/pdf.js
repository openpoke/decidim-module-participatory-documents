import PolygonEditor from "src/decidim/participatory_documents/polygon_editor";

// Call this on an annotation layer to initialize the polygon editor
window.InitAdminEditor = function(layer) {
  console.log("initAdminEditor on layer",layer);

  var editor = new PolygonEditor(layer);
  editor.onClick = function(box, e) {
    console.log("click", e, "box", box);
  };
};
