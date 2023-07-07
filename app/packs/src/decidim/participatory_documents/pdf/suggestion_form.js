export default class SuggestionForm {
  constructor(path, group = null) {
    this.path = path;
    this.group = group;
    this.div = document.getElementById("participation-modal");
    this.div.classList.remove("section", "document", "active");
    if (group) {
      this.div.classList.add("section");
    } else {
      this.div.classList.add("document");
    }
  }

  getCSRFToken() {
    const token =  document.getElementsByName("csrf-token")

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
    this.div.classList.add("active");
    this.addCloseHandler();
    this.addFormHandler();
    this.scrollToEnd();
  }

  addCloseHandler() {
    let close = document.getElementById("close-suggestions");
    let modal = document.getElementById("participation-modal");

    if (close && modal) {
      close.addEventListener("click", () => {
        modal.classList.remove("active");
        close.style.display = "none";
      }, { once: true });
    }
  }

  addFormHandler() {
    let form = document.getElementById("new_suggestion_");
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
            "X-CSRF-Token": this.getCSRFToken()
          },
          credentials: "include"
        }).then((response) => {
          return response.text();
        }).then((data) => {
          this.div.innerHTML = data;
          this.addFormHandler();
          this.addCloseHandler();
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
