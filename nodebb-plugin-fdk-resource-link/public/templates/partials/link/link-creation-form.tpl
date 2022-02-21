<form>
  <div class="plugin-fdk-resource-link panel panel-success">
    <div class="panel-body">
      <div class="form-group">    
        <label for="plugin-fdk-resource-link-editor-type">
          [[fdk-resource-link:type]]
        </label>    
        <select class="form-control" id="plugin-fdk-resource-link-editor-type"
        placeholder="[[fdk-resource-link:select_type]]">
          <option value="datasets">[[fdk-resource-link:datasets]]</option>
          <option value="dataservices">[[fdk-resource-link:dataservices]]</option>
          <option value="concepts">[[fdk-resource-link:concepts]]</option>          
          <option value="informationmodels">[[fdk-resource-link:informationmodels]]</option>          
          <option value="public_services_and_events">[[fdk-resource-link:public_services_and_events]]</option>
        </select>
        <p class="text-danger error-message">[[fdk-resource-link:select_type]]</p>
      </div>
      <div class="form-group dropdown">
        <label for="plugin-fdk-resource-link-editor-search">
          [[fdk-resource-link:search]]
        </label>  
        <input type="hidden" class="form-control" id="plugin-fdk-resource-link-editor-value">
        <input type="text" class="form-control" id="plugin-fdk-resource-link-editor-search"
        placeholder="[[fdk-resource-link:search]]">        
        <div id="plugin-fdk-resource-link-editor-dropdown" class="dropdown-content" />
      </div>
    </div>    
  </div>
</form>
