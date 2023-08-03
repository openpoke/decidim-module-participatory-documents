/* eslint-disable no-plusplus */

document.addEventListener("DOMContentLoaded", () => {
  const original = document.getElementById("pdf-iframe");

  if (original) {
    original.outerHTML = original.outerHTML.replace(/^<pdf-iframe/, "<iframe") +
                         original.outerHTML.replace(/pdf-iframe>$/, "iframe>");
  }
});
