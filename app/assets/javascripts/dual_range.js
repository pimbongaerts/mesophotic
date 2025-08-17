function initDualRange(minInput, maxInput, minDisplay, maxDisplay, hiddenInput, rangeHighlight) {
  const minRange = parseInt(minInput.min);
  const maxRange = parseInt(minInput.max);
  const rangeTag = document.getElementById(minInput.id.replace('_min', '_range_tag'));
  
  function updateValues() {
    let minVal = parseInt(minInput.value);
    let maxVal = parseInt(maxInput.value);
    
    // Ensure min never exceeds max
    if (minVal > maxVal) {
      minVal = maxVal;
      minInput.value = minVal;
    }
    
    // Ensure max never goes below min
    if (maxVal < minVal) {
      maxVal = minVal;
      maxInput.value = maxVal;
    }
    
    // Update display values in the single tag
    minDisplay.textContent = minVal;
    maxDisplay.textContent = maxVal;
    
    // Update hidden input with comma-separated values
    hiddenInput.value = minVal + ',' + maxVal;
    
    // Update range highlight
    updateRangeHighlight(minVal, maxVal, minRange, maxRange, rangeHighlight);
    
    // Position the single range tag in the center
    positionRangeTag(minVal, maxVal, minRange, maxRange, rangeTag);
  }
  
  function updateRangeHighlight(minVal, maxVal, minRange, maxRange, highlight) {
    const range = maxRange - minRange;
    const leftPercent = ((minVal - minRange) / range) * 100;
    const rightPercent = ((maxVal - minRange) / range) * 100;
    
    highlight.style.left = leftPercent + '%';
    highlight.style.width = (rightPercent - leftPercent) + '%';
  }
  
  function positionRangeTag(minVal, maxVal, minRange, maxRange, rangeTag) {
    const container = rangeTag.parentElement;
    const containerWidth = container.offsetWidth;
    const range = maxRange - minRange;
    
    // Account for thumb width (16px) in positioning calculations
    const thumbWidth = 16;
    const trackWidth = containerWidth - thumbWidth;
    
    const minPercent = (minVal - minRange) / range;
    const maxPercent = (maxVal - minRange) / range;
    
    // Calculate actual pixel positions accounting for thumb centers
    const minPixel = (thumbWidth / 2) + (minPercent * trackWidth);
    const maxPixel = (thumbWidth / 2) + (maxPercent * trackWidth);
    
    // Position tag at center of the actual thumb positions
    const centerPixel = (minPixel + maxPixel) / 2;
    const centerPercent = (centerPixel / containerWidth) * 100;
    
    rangeTag.style.left = centerPercent + '%';
    rangeTag.style.transition = 'none';
    rangeTag.offsetHeight;
  }
  
  // Simple event handling - let the browser handle the overlapping
  minInput.addEventListener('input', updateValues);
  maxInput.addEventListener('input', updateValues);
  
  // Initialize values on page load
  updateValues();
}