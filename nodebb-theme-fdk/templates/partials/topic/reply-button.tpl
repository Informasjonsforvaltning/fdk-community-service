<div component="topic/reply/container" class="fdk-topic-reply-btn btn-group action-bar bottom-sheet <!-- IF !privileges.topics:reply -->hidden<!-- ENDIF !privileges.topics:reply -->">
	<a href="{config.relative_path}/compose?tid={tid}&title={title}" class="btn btn-sm btn-primary" component="topic/reply" data-ajaxify="false" role="button">
    <i class="fa fa-reply visible-xs-inline"></i>
    <span class="visible-sm-inline visible-md-inline visible-lg-inline">
      <img src="/assets/plugins/nodebb-theme-fdk/images/icon-comment-sm.svg" alt="Ikon" />
      [[topic:reply]]
    </span>
  </a>
</div>

<!-- IF loggedIn -->
<!-- IF !privileges.topics:reply -->
<!-- IF locked -->
<div component="topic/reply/container" class="fdk-topic-reply-btn btn-group">
  <a component="topic/reply/locked" class="btn btn-sm btn-primary" disabled>
    <img src="/assets/plugins/nodebb-theme-fdk/images/icon-comment-sm.svg" alt="Ikon" />
    <i class="fa fa-lock"></i>
    [[topic:locked]]
  </a>
</div>

<!-- ENDIF locked -->
<!-- ENDIF !privileges.topics:reply -->

<!-- IF !locked -->
<div component="topic/reply/container" class="fdk-topic-reply-btn btn-group">
  <a component="topic/reply/locked" class="btn btn-sm btn-primary hidden" disabled>
    <img src="/assets/plugins/nodebb-theme-fdk/images/icon-comment-sm.svg" alt="Ikon" />
    <i class="fa fa-lock"></i>
    [[topic:locked]]
  </a>
</div>
<!-- ENDIF !locked -->

<!-- ELSE -->

<!-- IF !privileges.topics:reply -->
<div component="topic/reply/container" class="fdk-topic-reply-btn btn-group">
  <a component="topic/reply/guest" href="{config.relative_path}/login" class="btn btn-sm btn-primary">
    <img src="/assets/plugins/nodebb-theme-fdk/images/icon-comment-sm.svg" alt="Ikon" />
    [[topic:guest-login-reply]]
  </a>
</div>

<!-- ENDIF !privileges.topics:reply -->
<!-- ENDIF loggedIn -->
