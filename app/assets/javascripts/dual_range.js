function initDualRange(minInput, maxInput, minDisplay, maxDisplay, hiddenInput, rangeHighlight) {
  const minRange = parseInt(minInput.min);
  const maxRange = parseInt(minInput.max);
  const range = maxRange - minRange;
  const rangeTag = document.getElementById(minInput.id.replace('_min', '_range_tag'));

  function updateValues() {
    let minVal = parseInt(minInput.value);
    let maxVal = parseInt(maxInput.value);

    if (minVal > maxVal) {
      minVal = maxVal;
      minInput.value = minVal;
    }

    if (maxVal < minVal) {
      maxVal = minVal;
      maxInput.value = maxVal;
    }

    minDisplay.textContent = minVal;
    maxDisplay.textContent = maxVal;
    hiddenInput.value = minVal + ',' + maxVal;

    // Position highlight bar
    const leftPercent = ((minVal - minRange) / range) * 100;
    const rightPercent = ((maxVal - minRange) / range) * 100;
    rangeHighlight.style.left = leftPercent + '%';
    rangeHighlight.style.width = (rightPercent - leftPercent) + '%';

    // Position tag at centre of the selected range (pure percentage)
    const centerPercent = (leftPercent + rightPercent) / 2;
    rangeTag.style.left = centerPercent + '%';
  }

  minInput.addEventListener('input', updateValues);
  maxInput.addEventListener('input', updateValues);

  // Initialise immediately
  updateValues();
}
