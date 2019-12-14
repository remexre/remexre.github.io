(function() {
  // TODO: Are IIFEs still best practice?

  // Add the input element. This way, the feature only exists when it's supported!
  const searchBox = document.createElement("input");
  searchBox.autocomplete = "off";
  searchBox.id = "search";
  searchBox.placeholder = "Search...";
  document.querySelector("#search-container").appendChild(searchBox);

  // Add search functionality.
  const normalize = (s) => {
    return s.toLowerCase().replace(/[ \(\)]/g, "");
  };
  const updateSearch = () => {
    const searchTerm = normalize(searchBox.value);
    const pages = document.querySelectorAll(".page");
    for(let i = 0; i < pages.length; i++) {
      const classes = pages[i].classList;
      const normalized = normalize(pages[i].textContent);
      const show = normalized.search(searchTerm) >= 0;
      const hidden = classes.contains("hidden");
      if(show && hidden)
        classes.remove("hidden");
      else if(!show && !hidden)
        classes.add("hidden");
    }
  };
  searchBox.addEventListener("keydown", () => {
    window.setTimeout(updateSearch, 1);
  });
  searchBox.addEventListener("keypress", () => {
    window.setTimeout(updateSearch, 1);
  });
})();
