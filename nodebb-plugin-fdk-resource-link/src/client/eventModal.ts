import Benchpress from 'benchpress';
import { translate } from 'translator';
import formatting from 'composer/formatting';

import createLinkFactory, { CreateLink } from './createLink';

let initialized: Promise<CreateLink>;

const initialize = (): Promise<CreateLink> => {
  initialized = initialized || Benchpress.render('partials/link/link-creation-modal', {})
    .then(template => translate(template)).then((html) => {
      $('body').append(html);

      return createLinkFactory();
    });

  return initialized;
};

const prepareFormatting = (): void => {
  initialize().then((createEvent) => {
    formatting.addButtonDispatch('plugin-fdk-resource-link', (textarea) => {
      const $textarea = $(textarea);
      const oldVal = String($textarea.val());

      createEvent('', (link) => {
        $textarea.val(`${oldVal}${link}`);
        $textarea.trigger('input');
      });
    });
  });
};

export { initialize, prepareFormatting };
