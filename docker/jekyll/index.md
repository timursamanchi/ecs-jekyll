---
layout: default
title: "My GitHub Pages with Timur Samanchi"
---

# 🌟 Welcome to Timur's Quote Site - Kubernetes 🌟

This is my first GitHub Pages site using the **{{ site.theme_name }}**.

> Here will be the daily quote:  
> <span id="quote">Loading quote...</span>

<script>
  fetch('/quote/')
    .then(response => response.json())
    .then(data => {
      document.getElementById('quote').innerText = data.quote;
    })
    .catch(err => {
      document.getElementById('quote').innerText = 'Error loading quote';
    });
</script>

---

## Contact

You can find me on:
- GitHub: [timursamanchi](https://github.com/timursamanchi)
