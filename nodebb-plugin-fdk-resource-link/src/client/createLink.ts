export interface CreateLink {
  (data: string, callback: (link: string | null) => void): void;
}

const createLinkFactory = (): CreateLink => {
  const modal = $('#plugin-fdk-resource-link-editor').modal({
    backdrop: false,
    show: false,
  });
  const inputs = {
    value: modal.find('#plugin-fdk-resource-link-editor-value'),
  };

  const getSearchBaseUrl = () => {
    if (location.hostname.includes('staging')) {
      return 'https://search.staging.fellesdatakatalog.digdir.no';
    } else {
      return 'https://search.fellesdatakatalog.digdir.no';
    }
  };

  const getFdkBaseUrl = () => {
    if (location.hostname.includes('staging')) {
      return 'https://staging.fellesdatakatalog.digdir.no';
    } else {
      return 'https://data.norge.no';
    }
  };

  const getInputs = (): string => String(inputs.value.val()).trim();

  const alertFailure = (input: JQuery) => {
    input.closest('.form-group').addClass('has-error');
  };

  const getTitle = (suggestion: any) => {
    if (suggestion.title) {
      return suggestion.title.nb ?? suggestion.title.no ?? suggestion.title.en;
    }
    if (suggestion.prefLabel) {
      return suggestion.prefLabel.nb ?? suggestion.prefLabel.no ?? suggestion.prefLabel.en;
    }

    return 'n/a';
  };

  const getLink = (suggestion: any) => {
    switch (suggestion.index) {
      case 'datasets':
        return `[${getTitle(suggestion)}](${getFdkBaseUrl()}/datasets/${suggestion.id})`;
      case 'dataservices':
        return `[${getTitle(suggestion)}](${getFdkBaseUrl()}/dataservices/${suggestion.id})`;
      case 'concepts':
        return `[${getTitle(suggestion)}](${getFdkBaseUrl()}/concepts/${suggestion.id})`;
      case 'informationmodels':
        return `[${getTitle(suggestion)}](${getFdkBaseUrl()}/informationmodels/${suggestion.id})`;
      case 'events':
      case 'public_services':
        return `[${getTitle(suggestion)}](${getFdkBaseUrl()}/public-services-and-events/${suggestion.id})`;
      default:
        return null;
    }
  };

  const createLink: CreateLink = (_, callback) => {
    const submit = modal.find('#plugin-fdk-resource-link-editor-submit');
    const type = modal.find('#plugin-fdk-resource-link-editor-type');
    const search = modal.find('#plugin-fdk-resource-link-editor-search');
    const dropdown = modal.find('#plugin-fdk-resource-link-editor-dropdown');
    const value = modal.find('#plugin-fdk-resource-link-editor-value');

    type.val('datasets');
    search.val('');
    value.val('');

    modal.find('.form-group').removeClass('has-error');
    modal.modal('show');

    search.on('keyup', () => {
      const t = String(type.val()).trim();
      if (!t) {
        alertFailure(type);
      }

      dropdown.empty();
      dropdown.hide();

      const q = String(search.val()).trim();
      fetch(`${getSearchBaseUrl()}/suggestion/${t}?q=${q}`)
        .then(response => response.json())
        .then((data) => {
          dropdown.empty();
          dropdown.hide();

          data.suggestions.forEach((suggestion:any) => {
            dropdown.append($('<a></a>')
              .text(getTitle(suggestion))
              .attr('href', '#')
              .on('click', () => {
                const link = getLink(suggestion);
                if (link) {
                  search.val(getTitle(suggestion));
                  value.val(link);
                  dropdown.hide();
                }
              }));
          });

          if (data.suggestions.length > 0) {
            dropdown.show();
          }
        });
    });

    const submitOnClick = () => {
      const newLink = getInputs();

      modal.modal('hide');
      submit.off('click', submitOnClick);
      callback(newLink);
    };

    submit.on('click', submitOnClick);
  };

  return createLink;
};

export default createLinkFactory;
