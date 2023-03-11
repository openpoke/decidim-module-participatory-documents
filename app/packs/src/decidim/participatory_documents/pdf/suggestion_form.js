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

  populateArea(data) {
    this.div.innerHTML = data;
    this.div.classList.add("active");
    this.addCloseHandler();
    this.addFormHandler();
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
        fetch(event.target.action, {
          method: event.target.method,
          body: new URLSearchParams(new FormData(event.target)),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "text/html",
            "X-CSRF-Token": this.getCSRFToken()
          },
          credentials: "include"
        }).then((response) => {
          // if (response.ok === false && response.status === 400) { // validation
          //   return response.text();
          // }
          return response.text();
        }).then((data) => {
          console.log("data", data);
          this.div.innerHTML = data;
          this.addFormHandler();
          this.addCloseHandler();
        }).catch((error) => {
          console.error(error);
          // if(this.form && this.form[0]) {
          //   this.form.innerHTML = error.text();
          // }
        });
      }, {once: true});
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
