/* eslint-disable no-plusplus */

document.addEventListener("DOMContentLoaded", () => {
  const original = document.getElementById("pdf-iframe");
  const iframe = document.createElement("iframe");

  // Copy the children
  while (original.firstChild) {
    iframe.appendChild(original.firstChild);
  }

  // Copy the attributes
  for (let index = original.attributes.length - 1; index >= 0; --index) {
    iframe.attributes.setNamedItem(original.attributes[index].cloneNode());
  }

  // Replace it
  original.parentNode.replaceChild(iframe, original);
});
