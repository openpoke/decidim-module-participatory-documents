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
  if (fsElement) {
    button.classList.add("exit");
    button.textContent = button.dataset.exit;
  } else {
    button.classList.remove("exit");
    button.textContent = button.dataset.fullscreen;
  }
});
