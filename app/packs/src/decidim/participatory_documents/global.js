
window.toggleFullscreen = function() {
  let viewer = document.getElementById("outerContainer");
  
  if (document.fullscreenElement) {
    document.exitFullscreen();
  } else {
    viewer.requestFullscreen();
  }
}
