<div class="fdk-header">
  <div class="fdk-container container">
    <div class="fdk-logo">
      <a id="fdk-logo-link" href="/env/">
        <img src="/plugins/nodebb-theme-fdk/images/fdk-logo-positiv.svg" alt="FDK Logo">
      </a>
    </div>
    <nav class="fdk-links">
      <a href="/env/about">[[fdk:header.about]]</a>
      <a href="/env/organizations">[[fdk:header.organizations]]</a>
      <div class="fdk-tools" onMouseOver="toggleDropdown('fdk-tools-dropdown')" onMouseOut="toggleDropdown('fdk-tools-dropdown')">
        [[fdk:header.tools.tools]]
        <ul class="fdk-tools-dropdown" id="fdk-tools-dropdown">
          <li>
            <a href="/env/reports">[[fdk:header.tools.reports]]</a>
          </li>
          <li>
            <a href="/env/sparql">[[fdk:header.tools.sparql]]</a>
          </li>
        </ul>
      </div>
      <a class="active" href="/">[[fdk:header.community]]</a>
      <a href="/env/publishing">[[fdk:header.publishing]] <img class="fdk-text-icon" src="/plugins/nodebb-theme-fdk/images/icon-external-link-xs.svg" alt="Åpne"></a>
    </nav>
    <nav class="fdk-links-dropdown">
      <button class="fdk-links-button" onClick="toggleDropdown('fdk-dropdown-menu-header')">Meny <img class="fdk-text-icon" src="/plugins/nodebb-theme-fdk/images/icon-caret-down-sm.svg" alt="Åpne"></button>
      <ul id="fdk-dropdown-menu-header" class="fdk-dropdown-menu">
        <li>
          <a href="/env/about">[[fdk:header.about]]</a>
        </li>
        <li>
          <a href="/env/organizations">[[fdk:header.organizations]]</a>
        </li>
        <li>
          <a href="/env/reports">[[fdk:header.tools.reports]]</a>
        </li>
        <li>
          <a href="/env/sparql">[[fdk:header.tools.sparql]]</a>
        </li>
        <li>
          <a class="active" href="/">[[fdk:header.community]]</a>
        </li>
        <li>
          <a href="/env/publishing">[[fdk:header.publishing]] <img class="fdk-text-icon" src="/plugins/nodebb-theme-fdk/images/icon-external-link-xs.svg" alt="Åpne"></a>
        </li>
      </ul>
    </nav>
  </div>
</div>
