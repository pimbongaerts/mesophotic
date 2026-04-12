// Image drop zone with preview. Works with Turbo Drive.
// Usage: <div data-image-drop="field_id"> with a file input whose id matches field_id.

(function() {
  function initImageDrop(dropZone) {
    if (dropZone.dataset.imageDropInit) return;
    dropZone.dataset.imageDropInit = 'true';

    var fieldId = dropZone.dataset.imageDrop;
    var fileInput = document.getElementById(fieldId);
    var preview = dropZone.querySelector('[data-image-drop-preview]');
    var placeholder = dropZone.querySelector('[data-image-drop-placeholder]');

    if (!fileInput || !preview) return;

    dropZone.addEventListener('click', function() { fileInput.click(); });

    dropZone.addEventListener('dragover', function(e) {
      e.preventDefault();
      dropZone.style.borderColor = '#0d6efd';
      dropZone.style.backgroundColor = '#e7f1ff';
    });

    dropZone.addEventListener('dragleave', function() {
      dropZone.style.borderColor = '#dee2e6';
      dropZone.style.backgroundColor = '#f8f9fa';
    });

    dropZone.addEventListener('drop', function(e) {
      e.preventDefault();
      dropZone.style.borderColor = '#dee2e6';
      dropZone.style.backgroundColor = '#f8f9fa';
      var files = e.dataTransfer.files;
      if (files.length > 0 && files[0].type.match('image.*')) {
        fileInput.files = files;
        showPreview(files[0]);
      }
    });

    fileInput.addEventListener('change', function() {
      if (this.files.length > 0) { showPreview(this.files[0]); }
    });

    function showPreview(file) {
      var reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
        preview.style.display = '';
        if (placeholder) placeholder.style.display = 'none';
      };
      reader.readAsDataURL(file);
    }
  }

  function initAll() {
    document.querySelectorAll('[data-image-drop]').forEach(initImageDrop);
  }

  document.addEventListener('turbo:load', initAll);
  document.addEventListener('turbo:frame-load', initAll);
  document.addEventListener('DOMContentLoaded', initAll);
})();
