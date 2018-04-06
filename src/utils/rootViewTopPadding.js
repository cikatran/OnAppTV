import {
    Platform, Dimensions
} from 'react-native'

export function rootViewTopPadding() {
    if (Platform.OS === 'ios') {
        if (Dimensions.get('window').width == 375 && Dimensions.get('window').height == 812) {
            return 44;
        } else {
            return 24;
        }
    }
    return 0;
}