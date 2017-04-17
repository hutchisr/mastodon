import React from 'react';
import ReactDOM from 'react-dom';
import Perf from 'react-addons-perf';
import Mastodon from '../components/containers/mastodon';

if (!window.Intl) {
  require('intl');
  require('intl/locale-data/jsonp/en.js');
}

document.addEventListener('DOMContentLoaded', () => {
  const props = JSON.parse(document.getElementById('react-app').getAttribute('data-react-props'));
  ReactDOM.render(<Mastodon {...props} />, document.getElementById('react-app'));
});
