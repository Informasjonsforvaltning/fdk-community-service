import './locationHistory';

// eslint-disable-next-line camelcase, no-undef
__webpack_public_path__ = `${config.relative_path}/plugins/nodebb-plugin-fdk-resource-link/bundles/`;

jQuery.fn.size = jQuery.fn.size || function size(this: JQuery) { return this.length; };

$(() => {
  // ensure dependencies are loaded
  requirejs(['translator', 'benchpress'], () => {
    let eventModal: Promise<typeof import('./eventModal')>;
    $(window).on('action:composer.enhanced', () => {
      eventModal = eventModal || Promise.all([
        new Promise((resolve, reject) => requirejs(['composer/formatting'], formatting => (formatting ? resolve(formatting) : reject()))),
      ]).then(() => import('./eventModal'));

      eventModal.then(({ prepareFormatting }) => prepareFormatting());
    });
  });
});
