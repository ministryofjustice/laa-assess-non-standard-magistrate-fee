function waitForElm(selector) {
  return new Promise(function (resolve) {
    if (document.querySelector(selector)) {
      return resolve(document.querySelector(selector));
    }

    const observer = new MutationObserver(function (_mutations) {
      if (document.querySelector(selector)) {
        observer.disconnect();
        resolve(document.querySelector(selector));
      }
    });

    // If you get "parameter 1 is not of type 'Node'" error, see https://stackoverflow.com/a/77855838/492336
    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });
  });
}

document.addEventListener("DOMContentLoaded", function () {
  waitForElm("turbo-frame tr.govuk-table__row").then(function () {
    if (sessionStorage.getItem("jumpPage")) {
      const page = sessionStorage.getItem("jumpPage");
      waitForElm(`turbo-frame .govuk-pagination a[href$='page=${page}']`).then(
        function (elem) {
          setTimeout(function () {
            elem.click();
            sessionStorage.removeItem("jumpPage");
          }, 100);
        },
      );
    }

    if (sessionStorage.getItem("jumpIndex")) {
      const index = sessionStorage.getItem("jumpIndex");
      const elem = document.querySelector(
        `turbo-frame tr.govuk-table__row:nth-child(${index})`,
      );
      if (elem) {
        elem.scrollIntoView({ behavior: "smooth" });
        sessionStorage.removeItem("jumpIndex");
      }
    }

    waitForElm("turbo-frame").then(function (elem) {
      elem.addEventListener("click", function (e) {
        if (!e.target.closest(".govuk-pagination")) {
          const tab = e.target.closest("turbo-frame");
          const page = new URL(tab.src).searchParams.get("page");
          sessionStorage.setItem("jumpPage", page ?? 1);
          sessionStorage.setItem("jumpIndex", e.target.closest("tr").rowIndex);
          console.log(page ?? 1);
        }
      });
    });
  });
});
