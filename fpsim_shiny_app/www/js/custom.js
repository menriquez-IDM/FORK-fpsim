// FPsim Shiny App Custom JavaScript

$(document).ready(function() {
  
  // Smooth scrolling for anchor links
  $('a[href^="#"]').on('click', function(e) {
    e.preventDefault();
    var target = $(this.getAttribute('href'));
    if (target.length) {
      $('html, body').stop().animate({
        scrollTop: target.offset().top - 20
      }, 500);
    }
  });
  
  // Add loading indicator to buttons on click
  $('.btn-primary').on('click', function() {
    var btn = $(this);
    var originalText = btn.html();
    
    // Don't add spinner if already present
    if (btn.find('.fa-spinner').length === 0 && !btn.prop('disabled')) {
      btn.data('original-text', originalText);
      btn.html('<i class="fa fa-spinner fa-spin"></i> Processing...');
      btn.prop('disabled', true);
      
      // Re-enable after 30 seconds as failsafe
      setTimeout(function() {
        if (btn.data('original-text')) {
          btn.html(btn.data('original-text'));
          btn.prop('disabled', false);
        }
      }, 30000);
    }
  });
  
  // Reset button states when Shiny is idle
  $(document).on('shiny:idle', function() {
    $('.btn-primary').each(function() {
      var btn = $(this);
      if (btn.data('original-text')) {
        btn.html(btn.data('original-text'));
        btn.prop('disabled', false);
        btn.removeData('original-text');
      }
    });
  });
  
  // Console log for debugging
  console.log('FPsim Shiny App loaded');
  console.log('Custom JavaScript initialized');
  
  // Tooltip initialization (if using Bootstrap tooltips)
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
  
  // Add copy-to-clipboard functionality for code blocks
  $('pre code').each(function() {
    var code = $(this);
    var btn = $('<button class="btn btn-sm btn-outline-secondary copy-btn">Copy</button>');
    code.parent().css('position', 'relative');
    btn.css({
      'position': 'absolute',
      'top': '5px',
      'right': '5px'
    });
    btn.on('click', function() {
      navigator.clipboard.writeText(code.text()).then(function() {
        btn.text('Copied!');
        setTimeout(function() {
          btn.text('Copy');
        }, 2000);
      });
    });
    code.parent().append(btn);
  });
  
  // Keyboard shortcuts
  $(document).keydown(function(e) {
    // Ctrl/Cmd + R: Run simulation
    if ((e.ctrlKey || e.metaKey) && e.key === 'r') {
      e.preventDefault();
      $('#run_sim').click();
    }
    
    // Ctrl/Cmd + K: Reset parameters
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
      e.preventDefault();
      $('#reset_params').click();
    }
  });
  
  // Track simulation time
  var simStartTime;
  
  $(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'run_sim') {
      simStartTime = new Date();
      console.log('Simulation started at:', simStartTime);
    }
  });
  
  $(document).on('shiny:value', function(event) {
    if (event.name === 'sim_status' && simStartTime) {
      var endTime = new Date();
      var duration = (endTime - simStartTime) / 1000;
      console.log('Simulation completed in:', duration, 'seconds');
      simStartTime = null;
    }
  });
  
  // Add animation to cards on scroll
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.style.opacity = '0';
        entry.target.style.transform = 'translateY(20px)';
        setTimeout(function() {
          entry.target.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
        }, 100);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });
  
  document.querySelectorAll('.card').forEach(function(card) {
    observer.observe(card);
  });
  
});

// Custom Shiny input binding for enhanced sliders (future enhancement)
// Could add custom visualization of slider values, ranges, etc.

// Analytics tracking (placeholder for future implementation)
function trackEvent(category, action, label) {
  console.log('Event:', category, action, label);
  // Future: Send to analytics service
}

// Export functions for use in Shiny
window.fpsimApp = {
  trackEvent: trackEvent
};

