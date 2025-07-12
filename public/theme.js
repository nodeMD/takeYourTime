document.addEventListener('DOMContentLoaded', function() {
  const toggleBtn = document.getElementById('theme-toggle');
  if (!toggleBtn) return;
  
  const root = document.documentElement;
  
  // Update button icon based on current theme
  function updateButtonIcon() {
    const currentTheme = root.getAttribute('data-theme');
    toggleBtn.textContent = currentTheme === 'dark' ? '☀️' : '🌙';
  }

  // Toggle on click
  toggleBtn.addEventListener('click', () => {
    const current = root.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
    updateButtonIcon();
  });
  
  // Initialize button icon
  updateButtonIcon();
});
