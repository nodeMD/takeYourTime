class Stoper {
  constructor() {
    this.time = 0;
    this.running = false;
    this.interval = null;
    this.initialize();
  }

  initialize() {
    this.createStoperUI();
    this.loadStoperState();
    this.setupEventListeners();
  }

  createStoperUI() {
    const container = document.getElementById('stoper-container');
    if (!container) return;
    
    // Only create the inner stoper UI if it doesn't exist
    if (!container.querySelector('.stoper')) {
      const stopperHtml = `
        <div class="stoper">
          <div class="stoper-time">00:00.0</div>
          <div class="stoper-buttons">
            <button id="stoper-toggle" class="btn">Start</button>
            <button id="stoper-reset" class="btn">Reset</button>
          </div>
        </div>
      `;
      container.innerHTML = stopperHtml;
    }
  }

  loadStoperState() {
    fetch('/stoper/time')
      .then(response => {
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);
        return response.json();
      })
      .then(data => {
        console.log('Server response:', data);
        // Extract time and running state from the response
        const [minutes, seconds, tenths] = data.time.split(/[:.]/);
        this.time = (parseInt(minutes) * 60 * 1000) + (parseInt(seconds) * 1000) + (parseInt(tenths) * 100);
        this.running = data.running || false;
        
        // Update display and start timer if needed
        this.updateDisplay();
        if (this.running) {
          this.start();
        }
      })
      .catch(error => {
        console.error('Error loading stopper state:', error);
        // Set default values if there's an error
        this.time = 0;
        this.running = false;
        this.updateDisplay();
      });
  }

  setupEventListeners() {
    const toggleButton = document.getElementById('stoper-toggle');
    const resetButton = document.getElementById('stoper-reset');

    if (toggleButton) {
      toggleButton.addEventListener('click', () => {
        if (!this.running) {
          this.start();
        } else {
          this.stop();
        }
      });
    }

    if (resetButton) {
      resetButton.addEventListener('click', () => {
        this.reset();
      });
    }

    // Listen for visibility changes
    document.addEventListener('visibilitychange', () => this.checkVisibility());
  }

  start() {
    this.running = true;
    this.interval = setInterval(() => {
      this.time += 100; // Increment by 100ms
      this.updateDisplay();
    }, 100);
    this.updateButton();
  }

  stop() {
    clearInterval(this.interval);
    this.running = false;
    this.updateButton();
  }

  continue() {
    this.start();
  }

  reset() {
    clearInterval(this.interval);
    this.running = false;
    this.time = 0;
    this.updateDisplay();
    this.updateButton();
  }

  updateDisplay() {
    const totalSeconds = Math.floor(this.time / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const tenths = Math.floor((this.time % 1000) / 100);
    const formattedTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}.${tenths}`;
    
    const timeElement = document.querySelector('.stoper-time');
    if (timeElement) {
      timeElement.textContent = formattedTime;
    }
  }

  updateButton() {
    const toggleButton = document.getElementById('stoper-toggle');
    if (toggleButton) {
      toggleButton.textContent = this.running ? 'Stop' : 'Start';
    }
  }

  checkVisibility() {
    if (document.hidden) {
      // Stop the timer and save the current state
      clearInterval(this.interval);
      this.running = false;
      this.updateButton();
    } else {
      // Load the timer state and start if it was running
      this.loadStoperState();
    }
  }

  static init() {
    // Create stopper instance if container exists
    const container = document.getElementById('stoper-container');
    if (container) {
      const stopper = new Stoper();
      
      // Add event listener for page navigation
      window.addEventListener('beforeunload', () => {
        if (stopper.running) {
          stopper.stop();
        }
      });
    }
  }
}

// Initialize stopper when DOM is loaded
document.addEventListener('DOMContentLoaded', Stoper.init);

// Add error handling for fetch requests
window.addEventListener('error', (event) => {
  if (event.target instanceof XMLHttpRequest) {
    console.error('Network error occurred:', event);
  }
});
