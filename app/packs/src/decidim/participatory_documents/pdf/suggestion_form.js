import { initializeUploadFields } from "src/decidim/direct_uploads/upload_field";

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
      if (this.group) {
        this.div.classList.add("section");
      } else {
        this.div.classList.add("document");
      }
    }
  }

  close(callback = () => {}) {
    this.div.classList.remove("active");
    this.div.addEventListener("transitionend", () => {
      this.div.classList.remove("section", "document");
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

  populateArea(data) {
    this.div.innerHTML = data;
    const attachmentButtons = this.div.querySelectorAll("button[data-upload][data-dialog-open]");
    if (attachmentButtons.length) {
      initializeUploadFields(Array.from(attachmentButtons));
    }
    this.addCloseHandler();
    this.addFormHandler();
    this.scrollToEnd();
  }

  addCloseHandler() {
    let close = document.getElementById("close-suggestions");

    if (close) {
      close.addEventListener("click", () => {
        this.close();
      }, { once: true });
    }
  }

  addFormHandler() {
    let form = this.div.querySelector("form.send-suggestions-form") || document.getElementById("new_suggestion") || document.getElementById("new_suggestion_");
    if (form) {
      let fileInput = document.getElementById("file-upload-field");
      let fileNameContainer = document.getElementById("fileNameContainer");

      if (fileInput) {
        fileInput.addEventListener("change", () => {
          if (fileInput.files.length > 0) {
            fileNameContainer.textContent = fileInput.files[0].name;
          } else {
            fileNameContainer.textContent = "";
          }
        });
      }

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
