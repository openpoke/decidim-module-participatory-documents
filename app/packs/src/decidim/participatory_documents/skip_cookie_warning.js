/* eslint-disable no-plusplus */

document.addEventListener("turbo:load", () => {
  const original = document.getElementById("pdf-iframe");

  if (original) {
    original.outerHTML = original.outerHTML.replace(/^<pdf-iframe/, "<iframe").replace(/pdf-iframe>$/, "iframe>");
  }
});
