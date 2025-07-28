// Time widget update
function updateClock() {
  const now = new Date();
  const h = String(now.getHours()).padStart(2, '0');
  const m = String(now.getMinutes()).padStart(2, '0');
  document.getElementById('clock').textContent = `${h}:${m}`;
}
setInterval(updateClock, 1000);
updateClock();

// Carousel navigation
const carousel = document.getElementById('carousel');
const buttons = Array.from(document.querySelectorAll('.btn'));
let focusedIndex = 0;
const visibleCount = 5; // Number of visible items in the carousel

function focusButton(idx) {
  if (buttons.length === 0) return;
  focusedIndex = ((idx % buttons.length) + buttons.length) % buttons.length;
  buttons[focusedIndex].focus();
  // Show app name only for focused button
  buttons.forEach((btn, i) => {
    const appName = btn.querySelector('.app-name');
    if (appName) appName.style.display = (i === focusedIndex) ? 'block' : 'none';
  });
  // Center the focused button in the carousel, but don't scroll past the first/last entry
  const btn = buttons[focusedIndex];
  const carouselRect = carousel.getBoundingClientRect();
  const btnRect = btn.getBoundingClientRect();
  const scrollLeft = carousel.scrollLeft;
  const carouselStyle = window.getComputedStyle(carousel);
  const paddingLeft = parseInt(carouselStyle.paddingLeft) || 0;
  const paddingRight = parseInt(carouselStyle.paddingRight) || 0;
  const totalWidth = carousel.scrollWidth - paddingLeft - paddingRight;
  const center = carouselRect.width / 2;
  const btnCenter = btnRect.left - carouselRect.left + btnRect.width / 2;
  let targetScroll = scrollLeft + btnCenter - center;
  // Clamp scroll so first and last entries are fully visible
  const minScroll = 0;
  const maxScroll = carousel.scrollWidth - carouselRect.width;
  if (targetScroll < minScroll) targetScroll = minScroll;
  if (targetScroll > maxScroll) targetScroll = maxScroll;
  carousel.scrollLeft = targetScroll;
}

if (buttons.length) {
  focusButton(0);
}

buttons.forEach((btn, i) => {
  const isWebApp = btn.getAttribute('href') && !btn.getAttribute('href').startsWith('/launch/');
  btn.addEventListener('click', (e) => {
    if (isWebApp) {
      e.preventDefault();
      // Play select sound, then navigate after sound duration
      if (selectSound) {
        selectSound.currentTime = 0;
        selectSound.play();
        // Use actual sound duration if available, else fallback to 400ms
        const duration = selectSound.duration ? selectSound.duration * 1000 : 400;
        setTimeout(() => {
          window.location.href = btn.href;
        }, duration);
      } else {
        window.location.href = btn.href;
      }
    } else {
      e.preventDefault();
      // Play select sound
      if (selectSound) {
        selectSound.currentTime = 0;
        selectSound.play();
      }
      // Launch app in background
      fetch(btn.href, { method: 'POST' });
    }
  });
  btn.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight') {
      e.preventDefault();
      focusButton(focusedIndex + 1);
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      focusButton(focusedIndex - 1);
    } else if (e.key === 'Enter' || e.key === ' ') {
      if (isWebApp) {
        e.preventDefault();
        // Play select sound, then navigate after sound duration
        if (selectSound) {
          selectSound.currentTime = 0;
          selectSound.play();
          const duration = selectSound.duration ? selectSound.duration * 1000 : 400;
          setTimeout(() => {
            window.location.href = btn.href;
          }, duration);
        } else {
          window.location.href = btn.href;
        }
      } else {
        e.preventDefault();
        // Play select sound
        if (selectSound) {
          selectSound.currentTime = 0;
          selectSound.play();
        }
        // Launch app in background
        fetch(btn.href, { method: 'POST' });
      }
    }
  });
});

// Navigation sound on focus
const navSound = document.getElementById('nav-sound');
const selectSound = document.getElementById('select-sound');
if (navSound) {
  buttons.forEach(btn => {
    btn.addEventListener('focus', () => {
      navSound.currentTime = 0;
      navSound.play();
    });
  });
}
if (selectSound) {
  buttons.forEach(btn => {
    btn.addEventListener('mousedown', (e) => {
      selectSound.currentTime = 0;
      selectSound.play();
    });
    btn.addEventListener('keydown', (e) => {
      if ((e.key === 'Enter' || e.key === ' ') && !e.repeat) {
        selectSound.currentTime = 0;
        selectSound.play();
      }
    });
  });
}
