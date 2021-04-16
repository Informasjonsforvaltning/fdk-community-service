<!DOCTYPE html>
<html lang="{function.localeToHTML, userLang, defaultLang}" <!-- IF languageDirection -->data-dir="{languageDirection}" style="direction: {languageDirection};" <!-- ENDIF languageDirection --> >
<head>
	<title>{browserTitle}</title>
	{{{each metaTags}}}{function.buildMetaTag}{{{end}}}
	<link rel="stylesheet" type="text/css" href="{relative_path}/assets/client<!-- IF bootswatchSkin -->-{bootswatchSkin}<!-- END -->.css?{config.cache-buster}" />
	{{{each linkTags}}}{function.buildLinkTag}{{{end}}}

	<script>
		var config = JSON.parse('{{configJSON}}');
		var app = {
			user: JSON.parse('{{userJSON}}')
		};
    function toggleDropdown(id) {
      document.getElementById(id).classList.toggle("show");
    }
	</script>

	<!-- IF useCustomHTML -->
	{{customHTML}}
	<!-- END -->
	<!-- IF useCustomCSS -->
	<style>{{customCSS}}</style>
	<!-- END -->
</head>

<body class="{bodyClass} skin-<!-- IF bootswatchSkin -->{bootswatchSkin}<!-- ELSE -->noskin<!-- END -->">
  <nav id="menu" class="slideout-menu hidden">
		<!-- IMPORT partials/slideout-menu.tpl -->
	</nav>
	<nav id="chats-menu" class="slideout-menu hidden">
		<!-- IMPORT partials/chats-menu.tpl -->
	</nav>

	<main id="panel" class="slideout-panel">
		<!-- IMPORT fdk-header.tpl -->
		<!-- IMPORT fdk-breadcrumbs.tpl -->
		<nav class="navbar navbar-default header container" id="header-menu" component="navbar">
			<div class="container">
				<!-- IMPORT partials/menu.tpl -->
			</div>
		</nav>
    <div class="fdk-splash container" id="fdk-splash">
      <img src="/plugins/nodebb-theme-fdk/images/illustration-community.svg" alt="Community illustrasjon" />
      <div class="fdk-welcome">
        <h1>Community</h1>
        <h4>Velkommen til felles datakatalogs community! Det er en fornøyelse at du har funnet frem til oss. </h4>
        <p>Velkommen til felles datakatalogs community! Det er en fornøyelse at du har funnet frem til oss. Her kan du stille spørsmål om alt du måtte lure på om Felles datakatalog og informasjonsforvaltning, videre kan du delta i diskusjoner, vise frem prosjektene dine, knytte nye kontakter og finne nye samarbeid for utvikling og innovasjon. Forumet er åpent for alle, men for å skrive innlegg må du først registrere deg.
Formålet med forumet er å legge til rette for at data skal bli en verdiskapende ressurs for hele samfunnet – bli med og bidra til økt kunnskap, åpenhet og innovasjon.</p>
      </div>
    </div>
		<div class="container" id="content">
		<!-- IMPORT partials/noscript/warning.tpl -->
		<!-- IMPORT partials/noscript/message.tpl -->
