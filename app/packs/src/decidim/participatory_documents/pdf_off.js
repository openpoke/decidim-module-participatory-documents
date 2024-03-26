/* eslint-disable no-alert */

import PolygonViewer from "src/decidim/participatory_documents/pdf/polygon_viewer";
import "src/decidim/participatory_documents/pdf_notifications";
import "src/decidim/participatory_documents/global";

const openLogin = (evt) => {
  evt.stopPropagation();
  if (!window.parent) {
    // This shouldn't appear because is in a iframe, but just in case (or for developing)
    alert("Login required");
  }

  // add the rediret_to otherwise is going to be the iframe url and the user will lose the context
  const loginForm = window.parent.document.getElementById("login_new_user");
  let parts = loginForm.action.split("?")
  let params = new URLSearchParams(parts[1]);
  params.append("redirect_url", window.parent.location.href);
  loginForm.action = `${parts[0]}?${params.toString()}`;

  window.Decidim.currentDialogs.loginModal.open()
};

window.InitDocumentManagers = (options) => {
  options.globalSuggestionsButton.addEventListener("click", openLogin);
};

// Call this on an annotation layer to initialize the polygon viewer (public side)
window.InitPolygonViewer = (layer, boxes, options) => {
  let viewer = new PolygonViewer(layer, boxes, { i18n: options.i18n});

  viewer.onBoxClick = (box, evt) => {
    openLogin(evt);
  }

  return viewer;
};
