window.toggleFullscreen = () => {
  let viewer = document.getElementById("outerContainer");

  if (document.fullscreenElement) {
    document.exitFullscreen();
  } else {
    viewer.requestFullscreen();
  }
}

document.addEventListener("fullscreenchange", () => {
  let fsElement = document.fullscreenElement;

  const button = document.getElementById("fullscreenButton");
  const icon = button.querySelector("svg");
  if (fsElement) {
    button.classList.add("exit");
    button.innerHTML = icon.outerHTML + button.dataset.exit;
  } else {
    button.classList.remove("exit");
    button.innerHTML = icon.outerHTML + button.dataset.fullscreen;
  }
});
