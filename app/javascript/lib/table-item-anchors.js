document.addEventListener("DOMContentLoaded", function () {
  [...document.querySelectorAll("a#back-button")].map(function (btn) {
    btn.addEventListener("click", function (evt) {
      evt.preventDefault();
      history.back();
    });
    return btn;
  });
  [...document.querySelectorAll("table.govuk-table tr[id] a")].map(
    function (link) {
      link.addEventListener("click", function () {
        const nearestRow = link.closest("tr");
        if (nearestRow) {
          history.replaceState(history.state, "", `#${nearestRow.id}`);
        }
      });
      return link;
    },
  );
});
