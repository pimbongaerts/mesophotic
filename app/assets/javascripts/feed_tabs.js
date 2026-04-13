function switchFeed(platform) {
  var feeds = ['mastodon', 'bluesky'];
  var colors = { mastodon: '#595aff', bluesky: '#0085ff' };
  var muted = '#adb5bd';

  feeds.forEach(function(feed) {
    var container = document.getElementById('feed-' + feed);
    var logo = document.getElementById('logo-' + feed);
    if (feed === platform) {
      container.style.display = 'block';
      logo.style.color = colors[feed];
    } else {
      container.style.display = 'none';
      logo.style.color = muted;
    }
  });

  document.getElementById('feed-hashtag').style.color = colors[platform];
  var names = { mastodon: 'on Mastodon', bluesky: 'on Bluesky' };
  document.getElementById('feed-platform').textContent = names[platform];
}

function initFeedTabs() {
  document.querySelectorAll('[data-feed]').forEach(function(tab) {
    tab.addEventListener('click', function(e) {
      e.preventDefault();
      switchFeed(this.dataset.feed);
    });
  });
}

// After Bluesky feed loads, hide the tab if empty
function checkBlueskyFeed() {
  var blueskyTab = document.getElementById('tab-bluesky');
  if (!blueskyTab) return;

  var blueskyFeed = document.getElementById('feed-bluesky');
  if (!blueskyFeed) return;

  // Only act if the Bluesky feed has finished loading (no more spinner)
  var spinner = blueskyFeed.querySelector('.spinner-border');
  if (spinner) return;  // Still loading, wait for next event

  var hasContent = blueskyFeed.querySelector('.mastodon-status');
  blueskyTab.style.display = hasContent ? '' : 'none';
}

document.addEventListener('turbo:load', initFeedTabs);
document.addEventListener('turbo:frame-load', checkBlueskyFeed);
