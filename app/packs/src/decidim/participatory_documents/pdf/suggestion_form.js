export default class SuggestionForm {
  constructor(path, group = null) {
    this.path = path;
    this.group = group;
    this.div = document.getElementById("participation-modal");
    this.div.classList.remove("section", "document", "active");
    console.log(this.div.style, getComputedStyle(this.div))
    if (group) {
      this.div.classList.add("section");
    } else {
      this.div.classList.add("document");
    }
  }

  getCSRFToken() {
    return document.getElementsByName("csrf-token")[0].content;
  }

  setupFormToggle() {
    const options = document.getElementsByName("inputOption");
    const formContainer = document.getElementById("formContainer");
    const messageForm = document.getElementById("messageForm");
    const fileForm = document.getElementById("fileForm");

    /**
     * Scroll to the specified form
     * @param {HTMLElement} form - The form to scroll to
     * @returns {void}
     */
    const scrollToForm = (form) => {
      form.scrollIntoView({ behavior: "smooth", block: "start" });
    };

    Array.from(options).forEach(function(option) {
      option.addEventListener("change", function(event) {
        const value = event.target.value;
        if (value === "message") {
          messageForm.style.display = "block";
          fileForm.style.display = "none";
          scrollToForm(messageForm);
        } else if (value === "file") {
          messageForm.style.display = "none";
          fileForm.style.display = "block";
          scrollToForm(fileForm);
        }
      });
    });

    // Reset radio button selection on form open
    formContainer.addEventListener("click", (event) => {
      if (event.target === formContainer) {
        Array.from(options).forEach((option) => {
          option.checked = false;
        });
      }
    });
  };

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
    this.setupFormToggle();
    this.scrollToEnd();
  }

  addCloseHandler() {
    let close = document.getElementById("close-suggestions")
    if (close) {
      close.addEventListener("click", () => {
        console.log("close");
        this.div.classList.remove("active");
      }, {once: true});
    }
  }

  addFormHandler() {
    let form = document.getElementById("new_suggestion_");
    if (form) {
      form.addEventListener("submit", (event) => {
        event.preventDefault();

        let formData = new FormData(event.target);
        let fileInput = document.getElementById("suggestion_file");

        if (fileInput.files.length > 0) {
          formData.set("suggestion[file]", fileInput.files[0]);
        }

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
          console.log("data", data);
          this.div.innerHTML = data;
          this.addFormHandler();
          this.addCloseHandler();
          this.setupFormToggle();
        }).catch((error) => {
          console.error(error);
        });
      }, { once: true });
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
      throw new Error(" ");
    }).
      then((data) => {
        this.populateArea(data);
      }).
      catch((error) => {
        console.error(error);
      });
  }
}
