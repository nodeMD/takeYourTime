(function() {
  const toggleBtn = document.getElementById('theme-toggle');
  const root = document.documentElement;
  
  // Initialize theme
  const storedTheme = localStorage.getItem('theme');
  if (storedTheme) {
    root.setAttribute('data-theme', storedTheme);
    toggleBtn.textContent = storedTheme === 'dark' ? '☀️' : '🌙';
  } else {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    root.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
    toggleBtn.textContent = prefersDark ? '☀️' : '🌙';
  }

  // Toggle on click
  toggleBtn.addEventListener('click', () => {
    const current = root.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
    toggleBtn.textContent = next === 'dark' ? '☀️' : '🌙';
  });
})();
