// MIT License
// 
// Copyright (c) 2019 Nathan Ringo
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

(function() {
  // TODO: Are IIFEs still best practice?

  // Add the input element. This way, the feature only exists when it's supported!
  const searchBox = document.createElement("input");
  searchBox.autocomplete = "off";
  searchBox.classList.add("search");
  searchBox.placeholder = "Search...";
  document.querySelector("main").prepend(searchBox);

  // Add search functionality.
  const normalize = (s) => {
    return s.toLowerCase().replace(/[ \(\)]/g, "");
  };
  const updateSearch = () => {
    const searchTerm = normalize(searchBox.value);
    const items = document.querySelectorAll(".item");
    for(let i = 0; i < items.length; i++) {
      const classes = items[i].classList;
      const normalized = normalize(items[i].textContent);
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
