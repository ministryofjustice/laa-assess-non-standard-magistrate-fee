document.addEventListener("DOMContentLoaded", function () {
  [...document.querySelectorAll("a#back-button")].forEach(function (btn) {
    btn.addEventListener("click", function (evt) {
      evt.preventDefault();
      history.back();
    });
    return btn;
  });
  [...document.querySelectorAll("table[data-anchor-rows] tr[id] a")].forEach(
    function (link) {
      if (link.getAttribute('href')[0] === '#') {
        // This is a link that does not go to a different page
        return;
      }
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
