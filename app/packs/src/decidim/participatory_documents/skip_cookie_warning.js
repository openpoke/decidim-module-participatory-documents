/* eslint-disable no-plusplus */

document.addEventListener("turbo:load", () => {
  const original = document.getElementById("pdf-iframe");

  if (original) {
    original.outerHTML = original.outerHTML.replace(/^<pdf-iframe/, "<iframe").replace(/pdf-iframe>$/, "iframe>");
  }
});

document.addEventListener("dataconsent", () => {
  setTimeout(() => {
    document.querySelectorAll(".pdf-viewer-container .disabled-iframe").forEach((disabled) => {
      const original = Array.from(disabled.childNodes).find((node) => node.nodeType === Node.COMMENT_NODE);

      if (original) {
        const wrapper = document.createElement("div");
        wrapper.innerHTML = original.nodeValue;
        disabled.replaceWith(wrapper.firstElementChild);
      }
    });
  });
});
