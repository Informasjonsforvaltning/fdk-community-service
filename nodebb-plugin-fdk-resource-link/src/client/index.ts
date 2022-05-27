import './locationHistory';

// eslint-disable-next-line camelcase, no-undef
__webpack_public_path__ = `${config.relative_path}/assets/plugins/nodebb-plugin-fdk-resource-link/bundles/`;

jQuery.fn.size = jQuery.fn.size || function size(this: JQuery) { return this.length; };

$(() => {
    // ensure dependencies are loaded
    Promise.all([
      import('translator'),
      import('benchpress'),
    ]).then(() => {
      let eventModal: Promise<typeof import('./eventModal')>;
      $(window).on('action:composer.enhanced', () => {
        eventModal = eventModal || Promise.all([
          import('composer/formatting'),
        ]).then(() => import('./eventModal'));

        eventModal.then(({ prepareFormatting }) => prepareFormatting());
      });
    });
});
