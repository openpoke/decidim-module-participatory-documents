export default class SuggestionForm {
  constructor(div, path, group = null) {
    this.path = path;
    this.group = group;
    this.div = div;
  }

  open() {
    if (this.div.classList.contains("active")) {
      this.close(() => this.open());
    } else {
      // console.log("open!", "group:", this.group)
      this.div.classList.add("active");
      this.div.classList.toggle("section", Boolean(this.group));
      this.div.classList.toggle("document", !this.group);
    }
  }

  close(callback = () => {}) {
    this.div.classList.remove("active");
    this.div.addEventListener("transitionend", () => {
      if (!this.div.classList.contains("active")) {
        this.div.classList.remove("section", "document");
      }
      // console.log("end transition", this.div.classList);
      if (callback) {
        setTimeout(() => callback());
      }
    }, { once: true });
  }

  getCSRFToken() {
    const token = document.getElementsByName("csrf-token");

    return token.length && token[0].content;
  }

  // Sanitize internal path
  getPath() {
    return this.path.split("?")[0];
  }

  getQueryString() {
    return this.path.indexOf("?") === -1 // eslint-disable-line no-ternary
      ? ""
      : `?${this.path.split("?")[1]}`
  }

  getGroupUrl() {
    if (this.group === null) {
      return `${this.getPath()}/suggestions${this.getQueryString()}`;
    }
    return `${this.getPath()}/sections/${this.group}/suggestions${this.getQueryString()}`;

  }

  scrollToEnd() {
    this.div.scrollTop = this.div.scrollHeight;
  }

  clearArea() {
    this.div.querySelectorAll("[data-dialog-open]").forEach((button) => {
      const dialog = document.querySelector(`[data-dialog="${button.dataset.dialogOpen}"]`);

      if (dialog) {
        dialog.remove();
      }
      Reflect.deleteProperty(window.Decidim.currentDialogs, button.dataset.dialogOpen);
    });
    this.div.innerHTML = "";
  }

  populateArea(data) {
    this.clearArea();
    this.div.innerHTML = data;
    document.dispatchEvent(new CustomEvent("ajax:loaded", { detail: this.div }));
    this.updateExportCount();
    this.addCloseHandler();
    this.addFormHandler();
    this.scrollToEnd();
  }

  updateExportCount() {
    const list = this.div.querySelector("[data-suggestions-count]");
    const count = document.getElementById("exportSuggestionsCount");

    if (list && count) {
      count.textContent = list.dataset.suggestionsCount;
    }
  }

  addCloseHandler() {
    let close = document.getElementById("close-suggestions");

    if (close) {
      close.addEventListener("click", (event) => {
        event.preventDefault();
        this.close();
      });
    }
  }

  addFormHandler() {
    let form = this.div.querySelector("form.send-suggestions-form") || document.getElementById("new_suggestion") || document.getElementById("new_suggestion_");
    if (form) {
      form.addEventListener("submit", (event) => {
        event.preventDefault();

        let formData = new FormData(event.target);

        fetch(event.target.action, {
          method: event.target.method,
          body: formData,
          headers: {
            "X-CSRF-Token": this.getCSRFToken(),
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "text/html"
          },
          credentials: "include"
        }).then((response) => {
          return response.text();
        }).then((data) => {
          this.populateArea(data);
        }).catch((error) => {
          console.error(error);
        });
      });
      document.getElementById("suggestion_body").focus();
    }
  }

  fetchGroup() {
    this.clearArea();
    fetch(this.getGroupUrl(), {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Accept": "text/html"
      },
      credentials: "include"
      // body: JSON.stringify(data)
    }).then((response) => {
      if (response.ok) {
        return response.text();
      }
      throw new Error(response);
    }).
      then((data) => {
        this.populateArea(data);
      }).
      catch((error) => {
        console.error(error);
      });
  }
}
