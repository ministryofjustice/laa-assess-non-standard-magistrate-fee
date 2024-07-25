document.addEventListener("DOMContentLoaded", function () {
  [...document.querySelectorAll("table.govuk-table tr[id] a")].map(
    function (link) {
      link.addEventListener("click", function () {
        const nearestRow = link.closest("tr");
        if (nearestRow) {
          history.replaceState({}, "", `#${nearestRow.id}`);
        }
      });
    },
  );
});
