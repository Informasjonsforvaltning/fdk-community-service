$('document').ready(function() {
    window.FdkResourceLink = {
        selectedItem: undefined,

        onShow: () => {
            $('#plugin-fdk-resource-link-editor-search').off('keydown');
            $('#plugin-fdk-resource-link-editor-search').on('keydown', async (e) => {
                if(e.target.value.length < 3)
                    return;
    
                const type = $('#plugin-fdk-resource-link-editor-type').val();
                const response = await fetch(`${window.FdkResourceLink.getSearchBaseUrl()}/suggestions/${encodeURIComponent(type)}?q=${encodeURIComponent(e.target.value)}`);
                const suggestions = await response.json();
                const items = suggestions?.suggestions.map(({ id, title, searchType }) => {
                    return `<option data-id="${id}" data-type="${searchType}" value="${window.FdkResourceLink.getTitle(title)}"/>`;
                });
    
                // Render result list
                $('#plugin-fdk-resource-link-editor-results').html(items.join('\n'));
            });

            $('#plugin-fdk-resource-link-editor-search').on('input', () => {
                const title = $('#plugin-fdk-resource-link-editor-search').val();
                const { id, type } = $(`#plugin-fdk-resource-link-editor-results option[value='${title}']`).data();
                if(id && type) {
                    window.FdkResourceLink.selectedItem = { title, id, type };
                }
            })
        },

        getSearchBaseUrl: () => {
            if (location.hostname.includes('staging')) {
                return 'https://search.api.staging.fellesdatakatalog.digdir.no';
            } else {
                return 'https://search.api.fellesdatakatalog.digdir.no';
            }
        },

        getFdkBaseUrl: () => {
            if (location.hostname.includes('staging')) {
                return 'https://staging.fellesdatakatalog.digdir.no';
            } else {
                return 'https://data.norge.no';
            }
        },

        createLink: (textarea, selectionStart, selectionEnd) => {
            if(!window.FdkResourceLink.selectedItem) {
                return;
            }

            const { id, title, type } = window.FdkResourceLink.selectedItem;
            const baseUrl = window.FdkResourceLink.getFdkBaseUrl();
            var link;
            switch (type) {
                case 'DATASET':
                    link = `[${title}](${baseUrl}/datasets/${id})`;
                    break;
                case 'DATA_SERVICE':
                    link =  `[${title}](${baseUrl}/dataservices/${id})`;
                    break;
                case 'CONCEPT':
                    link =  `[${title}](${baseUrl}/concepts/${id})`;
                    break;
                case 'INFORMATION_MODEL':
                    link =  `[${title}](${baseUrl}/informationmodels/${id})`;
                    break;
                case 'EVENT':
                    link =  `[${title}](${baseUrl}/public-services/${id})`;
                    break;
                case 'SERVICE':
                    link =  `[${title}](${baseUrl}/events/${id})`;
                    break;
                default:
                    link =  null;
            }
    
            const $textarea = $(textarea);
            const oldVal = String($textarea.val());

            $textarea.val(`${oldVal}${link}`);
            $textarea.trigger('input');
        },

        getTitle: (title) => {
            if (title) {
              return title.nb ?? title.no ?? title.en;
            }    
            return 'n/a';
          }
    };

    require(['benchpress', 'bootbox', 'composer', 'composer/controls', 'translator'], 
        async function(benchpress, bootbox, composer, controls, translator) {
            composer.addButton('fdk-resource-link-btn', async function(textarea, selectionStart, selectionEnd) {
                const html = await benchpress.render('link-editor', {});
                bootbox.dialog({
                    message: html,
                    title: await translator.translate('[[fdk-resource-link:title]]'),
                    onEscape: true,
                    onShow: window.FdkResourceLink.onShow,
                    buttons: {
                        cancel: {
                            label: await translator.translate('[[fdk-resource-link:cancel]]'), 
                            className: 'btn-default',
                        },
                        createLink: {
                            label: await translator.translate('[[fdk-resource-link:createLink]]'),
                            className: 'btn-primary',
                            callback: function() {
                                window.FdkResourceLink.createLink(textarea, selectionStart, selectionEnd);
                            }
                        },
                    },
                });
            }, await translator.translate('[[fdk-resource-link:title]]'));
        });
});