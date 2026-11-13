<div class="flex-fill">
	<div class="mx-auto d-flex flex-column gap-3" style="max-width: 40rem;">
		<h2 class="fw-semibold tracking-tight">[[sso-oauth2-multiple:missing-email.title]]</h2>

		<p class="lead">[[sso-oauth2-multiple:missing-email.reason]]</p>

		<p>[[sso-oauth2-multiple:missing-email.instructions]]</p>

		{{{ if logoutUrl }}}
		<div>
			<a class="btn btn-primary" href="{logoutUrl}">
				<i class="fa fa-fw fa-right-from-bracket"></i> [[sso-oauth2-multiple:missing-email.logout]]
			</a>
		</div>
		<p class="text-sm text-muted">[[sso-oauth2-multiple:missing-email.logout-note]]</p>
		{{{ end }}}

		<p class="text-sm text-muted">[[sso-oauth2-multiple:missing-email.alternative]]</p>
	</div>
</div>
