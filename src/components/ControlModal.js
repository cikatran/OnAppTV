import {requireNativeComponent, ViewPropTypes} from 'react-native';
import PropTypes from 'prop-types';

let controlModal = {
    name: 'ControlModal',
    propTypes: {
        index: PropTypes.number,
        isLive: PropTypes.bool,
        items: PropTypes.array,
        continueWatching: PropTypes.array,
        onClose: PropTypes.func,
        onDetail: PropTypes.func,
        onAlert: PropTypes.func,
        onShare: PropTypes.func,
        onIndexChanged: PropTypes.func,
        onBookmark: PropTypes.func,
        onFavorite: PropTypes.func,
        onProgress: PropTypes.func,
        updateWatchingHistory: PropTypes.func,
        ...ViewPropTypes, // include the default view properties
    },
};

module.exports = requireNativeComponent('RNControlModal', controlModal, {
    nativeOnly: {onClose: true, onDetail: true, onAlert: true, onShare: true, onIndexChanged: true, onBookmark: true, onFavorite: true }
});