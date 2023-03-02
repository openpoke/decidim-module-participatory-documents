window.addEventListener("load", () => {
  const box = document.querySelector(".box-preview .box");
  const color = document.querySelector("#document_box_color");
  const opacity = document.querySelector("#document_box_opacity");
  const applyColor = () => {
    box.style.background = color.value + parseInt(opacity.value * 255 / 100, 10).toString(16);
    box.style.borderColor = color.value;
  };

  if (box && color && opacity) {
    color.addEventListener("change", applyColor);
    opacity.addEventListener("change", applyColor);
  }
});
