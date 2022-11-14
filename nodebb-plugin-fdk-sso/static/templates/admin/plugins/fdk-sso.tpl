<form role="form" id="fdk-sso-settings">
	<div class="row">
		<div class="col-sm-2 col-12 settings-header">FDK Single Sign-On Settings</div>
		<div class="col-sm-10 col-12">
			<div class="mb-3">
  				<label class="form-label" for="keycloak-config">Keycloak OIDC JSON</label>
  				<textarea class="form-control" rows="10" id="keycloak-config" name="keycloak-config"></textarea>
			</div>
			<div class="mb-3">
  				<label class="form-label" for="valid-redirects">Valid redirect hostnames. Seperate with comma (,)</label>
  				<input type="text" class="form-control" id="valid-redirects" name="valid-redirects"></input>

			</div>
			<div class="mb-3">
				<label class="form-label" for="callback-url">Callback URL</label>
				<input type="text" class="form-control" id="callback-url" name="callback-url"></input>
			</div>
			<div class="mb-3">
				<label class="form-label" for="admin-url">Admin URL</label>				
				<input type="text" class="form-control" id="admin-url" name="admin-url"></input>
			</div>
			<div class="mb-3">
  				<label class="form-label" for="token-mapper">Token mapping</label>
  				<textarea class="form-control" rows="8" id="token-mapper" name="token-mapper"></textarea>
			</div>
			<div class="mb-3">
  				<label class="form-label" for="client-role-to-group-mapper">Client role to group mapping. Format JSON.</label>
  				<textarea class="form-control" rows="8" id="client-role-to-group-mapper" name="client-role-to-group-mapper"></textarea>
			</div>
		</div>
	</div>
</form>

<button id="save" class="floating-button mdl-button mdl-js-button mdl-button--fab mdl-js-ripple-effect mdl-button--colored">
	<i class="material-icons">save</i>
</button>
