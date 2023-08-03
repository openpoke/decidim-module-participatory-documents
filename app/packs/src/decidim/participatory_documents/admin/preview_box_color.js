window.addEventListener("load", () => {
  const root = document.querySelector("html");
  const color = document.querySelector("#document_box_color");
  const opacity = document.querySelector("#document_box_opacity");
  const applyColor = () => {
    root.style.setProperty("--box-color", color.value);
    root.style.setProperty("--box-color-rgba", color.value + parseInt(opacity.value * 255 / 100, 10).toString(16));
  };

  if (color && opacity) {
    color.addEventListener("change", applyColor);
    opacity.addEventListener("change", applyColor);
  }
});
