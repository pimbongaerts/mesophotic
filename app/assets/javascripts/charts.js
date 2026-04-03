// Auto-initialize Highcharts, Highcharts Maps, and WordCloud2 from data attributes.
// Works with both direct rendering and render_async injection (no inline scripts needed).

(function() {
  var resizeObservers = [];

  function cleanupObservers() {
    resizeObservers.forEach(function(observer) { observer.disconnect(); });
    resizeObservers = [];
  }

  function initAll(scope) {
    var root = (scope && scope.target instanceof HTMLElement) ? scope.target : document;
    root.querySelectorAll('[data-chart]:not([data-chart-init])').forEach(initChart);
    root.querySelectorAll('[data-wordcloud]:not([data-chart-init])').forEach(initWordcloud);
  }

  // --- Highcharts ---

  function initChart(el) {
    var type = el.dataset.chart;
    var init = chartTypes[type];
    if (init) {
      init(el);
      el.dataset.chartInit = 'true';
    }
  }

  function baseOpts(el) {
    return {
      title: { text: '' },
      credits: { enabled: false },
      legend: { enabled: false }
    };
  }

  function simpleChart(el, chartType, opts) {
    var categories = JSON.parse(el.dataset.categories);
    var values = JSON.parse(el.dataset.values);
    var unit = el.dataset.unit || '';
    var config = baseOpts(el);
    config.chart = { type: chartType };
    config.xAxis = { categories: categories };
    config.yAxis = { title: { text: opts.yAxisTitle || '' } };
    config.series = [{ name: unit, data: values }];
    if (opts.inverted) config.chart.inverted = true;
    if (opts.stacking) config.plotOptions = { area: { stacking: opts.stacking } };
    Highcharts.chart(el, config);
  }

  function seriesChart(el, chartType, opts) {
    var categories = JSON.parse(el.dataset.categories);
    var seriesData = JSON.parse(el.dataset.series);
    var unit = el.dataset.unit || '';
    var config = baseOpts(el);
    config.chart = { type: chartType };
    if (opts.inverted) config.chart.inverted = true;
    config.xAxis = { categories: categories };
    config.yAxis = { title: { text: unit } };
    config.plotOptions = {};
    config.plotOptions[chartType] = { stacking: opts.stacking || 'normal' };
    if (opts.legend) config.legend = { enabled: true, itemWidth: 150 };
    config.series = seriesData;
    Highcharts.chart(el, config);
  }

  function mapChart(el, opts) {
    var data = JSON.parse(el.dataset.values);
    var unit = el.dataset.unit || 'publication(s)';
    var config = baseOpts(el);
    config.mapNavigation = { enabled: !!opts.nav, buttonOptions: { verticalAlign: 'top' } };
    config.series = [
      { name: 'Countries', mapData: Highcharts.maps['custom/world-continents'], color: '#E0E0E0', enableMouseTracking: false },
      { type: 'mapbubble', name: opts.seriesName || 'Study locations', data: data,
        tooltip: { pointFormat: opts.tooltipFormat || ('{point.name}: {point.z} ' + unit) },
        maxSize: '12%' }
    ];
    if (opts.dataLabels) config.series[1].dataLabels = { enabled: true, format: '{point.name}' };
    if (opts.clickable) {
      config.exporting = { enabled: false };
      config.chart = { backgroundColor: 'rgba(255, 255, 255, 0)' };
      config.xAxis = { minRange: 1 };
      config.yAxis = { minRange: 1 };
      config.plotOptions = { series: { cursor: 'pointer', point: { events: {
        click: function() { window.location = this.options.url; }
      } } } };
    }
    Highcharts.mapChart(el, config);
  }

  var chartTypes = {
    'bar': function(el) { simpleChart(el, 'bar', {}); },
    'area': function(el) { simpleChart(el, 'area', { yAxisTitle: el.dataset.unit }); },
    'depth': function(el) { simpleChart(el, 'area', { inverted: true, stacking: 'normal', yAxisTitle: el.dataset.unit }); },
    'pie': function(el) {
      var data = JSON.parse(el.dataset.values);
      var unit = el.dataset.unit || '';
      Highcharts.chart(el, {
        colors: ['#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
        chart: { type: 'pie' }, title: { text: '' }, credits: { enabled: false }, legend: { enabled: false },
        plotOptions: { pie: { size: 100, dataLabels: { enabled: true, distance: 0, style: { fontWeight: 'bold', color: 'white' } },
          startAngle: -90, endAngle: 90, center: ['50%', '90%'] } },
        series: [{ name: unit, data: data }]
      });
    },
    'area-series': function(el) { seriesChart(el, 'area', {}); },
    'column-series': function(el) { seriesChart(el, 'column', {}); },
    'depth-series': function(el) { seriesChart(el, 'area', { inverted: true, stacking: 'percent', legend: true }); },
    'map': function(el) { mapChart(el, {}); },
    'map-clickable': function(el) { mapChart(el, { nav: true, clickable: true, dataLabels: true, seriesName: 'Locations', tooltipFormat: '{point.name}' }); },
  };

  // --- WordCloud2 ---

  function initWordcloud(el) {
    var list = JSON.parse(el.dataset.wordcloud);
    var associations = JSON.parse(el.dataset.associations);

    var render = function() {
      WordCloud(el, {
        list: list,
        color: 'black',
        drawOutOfBound: false,
        shape: 'square',
        weightFactor: function(size) { return Math.pow(size, 0.67) * 50; },
        classes: function(word) {
          for (var key in associations) {
            if (associations[key][word] != undefined) return 'associated';
          }
        },
        hover: function() {
          document.body.style.cursor = document.body.style.cursor === 'pointer' ? 'default' : 'pointer';
        },
        click: function(item) {
          for (var key in associations) {
            if (associations[key][item[0]] != undefined) {
              window.location.href = '/' + key + '/' + associations[key][item[0]];
              return;
            }
          }
          window.location.href = '/publications?search=' + item[0];
        }
      });
    };

    render();
    var observer = new ResizeObserver(render);
    observer.observe(el);
    resizeObservers.push(observer);
    el.dataset.chartInit = 'true';
  }

  // --- Event listeners ---

  document.addEventListener('turbolinks:load', initAll);
  document.addEventListener('render_async_load', initAll);
  document.addEventListener('turbolinks:before-cache', cleanupObservers);
})();
