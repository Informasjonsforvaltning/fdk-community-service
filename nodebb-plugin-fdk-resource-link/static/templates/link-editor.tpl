<div class="fdk-resource-link-modal">
  <form>
    <div class="plugin-fdk-resource-link panel panel-success">
      <div class="panel-body">
        <div class="form-group">    
          <label for="plugin-fdk-resource-link-editor-type">
            [[fdk-resource-link:type]]
          </label>    
          <select class="form-control" id="plugin-fdk-resource-link-editor-type"
          placeholder="[[fdk-resource-link:typePlaceholder]]">
            <option value="datasets">[[fdk-resource-link:dataset]]</option>
            <option value="dataservices">[[fdk-resource-link:dataservice]]</option>
            <option value="concepts">[[fdk-resource-link:concept]]</option>          
            <option value="informationmodels">[[fdk-resource-link:informationModel]]</option>          
            <option value="service">[[fdk-resource-link:service]]</option>
            <option value="events">[[fdk-resource-link:event]]</option>
          </select>
        </div>
        <div class="form-group dropdown">
          <label for="plugin-fdk-resource-link-editor-search">
            [[fdk-resource-link:search]]
          </label>  
          <input list="plugin-fdk-resource-link-editor-results" class="form-control" id="plugin-fdk-resource-link-editor-search"
            placeholder="[[fdk-resource-link:searchPlaceholder]]">
          <datalist id="plugin-fdk-resource-link-editor-results" />
        </div>
      </div>    
    </div>
  </form>
</div>