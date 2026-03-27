$(document).on('turbolinks:load', function() {
  var profileCache = {};

  $('.mastodon-avatar').each(function() {
    var el = $(this);
    var profileUrl = el.data('profile-url');
    var contentUrl = el.data('content-url');
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
    $.ajax({
      url: instance + '/api/v1/accounts/lookup',
      data: { acct: username },
      dataType: 'json',
      timeout: 5000,
      success: function(data) {
        var profile = { avatar: data.avatar, display_name: data.display_name };
        profileCache[cacheKey] = profile;
        applyProfile(el, statusEl, profile);
      }
    });
  }

  function fetchStatusAccount(instance, statusId, cacheKey, el, statusEl) {
    $.ajax({
      url: instance + '/api/v1/statuses/' + statusId,
      dataType: 'json',
      timeout: 5000,
      success: function(data) {
        if (data && data.account) {
          var profile = { avatar: data.account.avatar, display_name: data.account.display_name };
          profileCache[cacheKey] = profile;
          applyProfile(el, statusEl, profile);

          // Also update the handle text
          if (data.account.acct) {
            var handleEl = statusEl.find('.mastodon-handle');
            if (handleEl.length) {
              handleEl.text('@' + data.account.acct);
            }
          }
        }
      }
    });
  }

  function applyProfile(avatarEl, statusEl, profile) {
    if (profile.avatar) {
      avatarEl.html('<img src="' + profile.avatar + '" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">');
    }
    if (profile.display_name && statusEl.length) {
      var nameEl = statusEl.find('.mastodon-display-name');
      if (nameEl.length) {
        nameEl.text(profile.display_name);
        nameEl.show();
      }
    }
  }
});
