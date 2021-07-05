function getEnvironment() {
	const host = window.location.hostname.split(".")

	if (host.includes("staging") || host.includes("localhost")) {
		return "staging";
	} else if (host.includes("demo")) {
		return "demo";
	}
	return "prod";
}

// Redirect user to register form
function registerUser() {
	const environment = getEnvironment();
		var href = "";
		switch (environment) {
			case "demo":
				href = 'https://user.difi.no/auth/realms/difi/protocol/openid-connect/registrations?client_id=felles-datakatalog-demo&response_type=code&scope=openid%20email&redirect_uri=https%3A%2F%2Fsso.demo.fellesdatakatalog.digdir.no%2Fauth%2Frealms%2Ffdk%2Fbroker%2Ffelles-datakatalog-demo%2Fendpoint';
				break;
			case "prod":
				href = 'https://user.difi.no/auth/realms/difi/protocol/openid-connect/registrations?client_id=felles-datakatalog&response_type=code&scope=openid%20email&redirect_uri=https%3A%2F%2Fsso.fellesdatakatalog.digdir.no%2Fauth%2Frealms%2Ffdk%2Fbroker%2Ffelles-datakatalog%2Fendpoint';
				break;
			case "staging":
			default:
				href = 'https://user.difi.no/auth/realms/difi/protocol/openid-connect/registrations?client_id=felles-datakatalog-staging&response_type=code&scope=openid%20email&redirect_uri=https%3A%2F%2Fsso.staging.fellesdatakatalog.digdir.no%2Fauth%2Frealms%2Ffdk%2Fbroker%2Ffelles-datakatalog-staging%2Fendpoint';
				break;
		}
		window.location.href = href;
}

$(document).ready(function() {

	$('main').on("DOMNodeInserted", function (e) {
		if (window.location.pathname !== '/') {
			let bc = $('main > div > ol.breadcrumb')[0];
			if (bc) {
				$('div.fdk-breadcrumbs-container').empty();
				$('div.fdk-breadcrumbs-container')[0].appendChild(bc);
				$('div.fdk-breadcrumbs').show();
			}
		} else {
			$('div.fdk-breadcrumbs').hide();
		}
	});

	function toggleSplash(path) {
		if (path === "/") {
			document.getElementById("fdk-splash").style.display = "inherit";
		} else {
			document.getElementById("fdk-splash").style.display = "none";
		}
	}

	window.addEventListener('popstate', function () {toggleSplash(location.pathname)});

	(function (history) {
		var pushState = history.pushState;
		history.pushState = function (data, title, url) {
			toggleSplash(url)
			return pushState.apply(history, [data, title, url]);
		};

		toggleSplash(location.pathname)
	})(window.history);

	function setLinkEnvironments() {
		var anchors = document.getElementsByTagName("a");

		for (var i = 0; i < anchors.length; i++) {
			var envIndex = anchors[i].href.indexOf("/env/");
			if (envIndex !== -1) {
				const environment = getEnvironment();
				const path = anchors[i].href.substring(envIndex + "/env/".length);
				var href = "";
				switch (environment) {
					case "demo":
						href = "https://demo.fellesdatakatalog.digdir.no/" + path;
						break;
					case "prod":
						href = "https://data.norge.no/" + path;
						break;
					case "staging":
					default:
						href = "https://www.staging.fellesdatakatalog.digdir.no/" + path;
						break;
				}
				anchors[i].href = href

			}
		}
	}

	setLinkEnvironments();
});

function toggleDropdown(id) {
	document.getElementById(id).classList.toggle("show");
}

function abortRegistration() {
	const { app } = window;
	console.log("abort registration")
	fetch( "/register/abort", {
		method: 'POST',
	}).then( () => app.logout('/') );
}
