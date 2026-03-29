document.addEventListener('turbolinks:load', function() {
  var profileCache = {};

  document.querySelectorAll('.mastodon-avatar').forEach(function(el) {
    var profileUrl = el.dataset.profileUrl;
    var contentUrl = el.dataset.contentUrl;
    if (!profileUrl) return;

    var statusEl = el.closest('.mastodon-status');

    // Try Mastodon-style: https://instance/@username
    var mastodonMatch = profileUrl.match(/^(https?:\/\/[^/]+)\/@(.+)$/);
    if (mastodonMatch) {
      var instance = mastodonMatch[1];
      var username = mastodonMatch[2];
      var cacheKey = instance + '/@' + username;

      if (profileCache[cacheKey]) {
        applyProfile(el, statusEl, profileCache[cacheKey]);
      } else {
        fetchAccountLookup(instance, username, cacheKey, el, statusEl);
      }
    } else if (contentUrl) {
      // Non-Mastodon (Misskey/Firefish/etc): fetch status to get account info
      var statusMatch = contentUrl.match(/^(https?:\/\/[^/]+)\/notes\/(.+)$/);
      if (statusMatch) {
        var instance = statusMatch[1];
        var statusId = statusMatch[2];
        var cacheKey = contentUrl;

        if (profileCache[cacheKey]) {
          applyProfile(el, statusEl, profileCache[cacheKey]);
        } else {
          fetchStatusAccount(instance, statusId, cacheKey, el, statusEl);
        }
      }
    }
  });

  function fetchAccountLookup(instance, username, cacheKey, el, statusEl) {
    var url = instance + '/api/v1/accounts/lookup?acct=' + encodeURIComponent(username);
    var controller = new AbortController();
    var timeoutId = setTimeout(function() { controller.abort(); }, 5000);

    fetch(url, { signal: controller.signal })
      .then(function(response) {
        clearTimeout(timeoutId);
        if (!response.ok) return;
        return response.json();
      })
      .then(function(data) {
        if (!data) return;
        var profile = { avatar: data.avatar, display_name: data.display_name };
        profileCache[cacheKey] = profile;
        applyProfile(el, statusEl, profile);
      })
      .catch(function() { clearTimeout(timeoutId); });
  }

  function fetchStatusAccount(instance, statusId, cacheKey, el, statusEl) {
    var url = instance + '/api/v1/statuses/' + encodeURIComponent(statusId);
    var controller = new AbortController();
    var timeoutId = setTimeout(function() { controller.abort(); }, 5000);

    fetch(url, { signal: controller.signal })
      .then(function(response) {
        clearTimeout(timeoutId);
        if (!response.ok) return;
        return response.json();
      })
      .then(function(data) {
        if (!data || !data.account) return;
        var profile = { avatar: data.account.avatar, display_name: data.account.display_name };
        profileCache[cacheKey] = profile;
        applyProfile(el, statusEl, profile);

        // Also update the handle text
        if (data.account.acct) {
          var handleEl = statusEl ? statusEl.querySelector('.mastodon-handle') : null;
          if (handleEl) {
            handleEl.textContent = '@' + data.account.acct;
          }
        }
      })
      .catch(function() { clearTimeout(timeoutId); });
  }

  function applyProfile(avatarEl, statusEl, profile) {
    if (profile.avatar) {
      avatarEl.innerHTML = '<img src="' + profile.avatar + '" style="width: 100%; height: 100%; object-fit: cover; border-radius: 0.3rem;">';
    }
    if (profile.display_name && statusEl) {
      var nameEl = statusEl.querySelector('.mastodon-display-name');
      if (nameEl) {
        nameEl.textContent = profile.display_name;
        nameEl.style.display = '';
      }
    }
  }
});
