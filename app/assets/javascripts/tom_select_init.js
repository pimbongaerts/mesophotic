// Initialise Tom Select on <select data-tom-select> elements.
// Uses MutationObserver to init as soon as elements appear in the DOM,
// avoiding the flash of unstyled select.

function initTomSelectOn(el) {
  if (el.tomselect) return;
  var ts = new TomSelect(el, {
    create: false,
    allowEmptyOption: true,
    selectOnTab: true,
    maxOptions: el.dataset.maxOptions ? parseInt(el.dataset.maxOptions) : 1000,
    onFocus: function() {
      this._previousValue = this.getValue();
      this.clear(true);
    },
    onBlur: function() {
      if (!this.getValue()) {
        this.setValue(this._previousValue || '', true);
      }
    },
    placeholder: el.dataset.placeholder || 'Search\u2026'
  });
  if (el.dataset.tomSelect === 'navigate') {
    ts.on('change', function(value) {
      if (value) window.location = value;
    });
  }
}

// Watch for new select[data-tom-select] elements appearing in the DOM
var observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    mutation.addedNodes.forEach(function(node) {
      if (node.nodeType !== 1) return;
      if (node.matches && node.matches('select[data-tom-select]')) {
        initTomSelectOn(node);
      }
      if (node.querySelectorAll) {
        node.querySelectorAll('select[data-tom-select]').forEach(initTomSelectOn);
      }
    });
  });
});

observer.observe(document.documentElement, { childList: true, subtree: true });

// Also handle Turbo navigation
document.addEventListener('turbo:load', function() {
  document.querySelectorAll('select[data-tom-select]').forEach(initTomSelectOn);
});
document.addEventListener('turbo:frame-load', function() {
  document.querySelectorAll('select[data-tom-select]').forEach(initTomSelectOn);
});
document.addEventListener('turbo:before-cache', function() {
  document.querySelectorAll('select[data-tom-select]').forEach(function(el) {
    if (el.tomselect) el.tomselect.destroy();
  });
});
