import * as actionTypes from '../actions/actionTypes';

const initialState = {
    data: null,
    fetched: false,
    isFetching: false,
    error: false,
};

export default function videoFormatReducer(state = initialState, action) {
    switch (action.type) {
        case actionTypes.FETCHING_VIDEO_FORMAT:
            return {
                ...state,
                data: null,
                isFetching: true
            };
        case actionTypes.FETCH_VIDEO_FORMAT_SUCCESS:
            return {
                ...state,
                isFetching: false,
                fetched: true,
                data: action.data
            };
        case actionTypes.FETCH_VIDEO_FORMAT_FAILURE:
            return {
                ...state,
                isFetching: false,
                fetched: true,
                error: true,
                errorMessage: action.errorMessage
            };
        default:
            return state
    }
};