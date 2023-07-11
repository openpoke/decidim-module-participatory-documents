window.showInfo = (title, options = {}) => {
  const info = document.getElementById("notifications");
  info.innerHTML = title;
  info.classList.add("show");
  info.classList.remove("alert");
  if (options && options.class) {
    info.classList.add(options.class);
  }
  if (window.notificationTimeout) {
    clearTimeout(window.notificationTimeout);
  }
  window.notificationTimeout = setTimeout(() => {
    info.classList.remove("show")
  }, options && options.delay || 3000);
};

window.showAlert = (title, options = {}) => {
  options.class = "alert"
  window.showInfo(title, options);
};
