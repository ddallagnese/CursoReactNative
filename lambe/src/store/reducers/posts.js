import {
    SET_POSTS,
    ADD_COMMENT,
    ADD_POST,
    CREATING_POST,
    POST_CREATED
} from '../actions/actionTypes'

const initialState = {
    posts: [{
        id: Math.random(),
        nickname: 'Nickname',
        email: 'email',
        image: require('../../../assets/imgs/fence.jpg'),
        comments: [{
            nickname: 'nick com 1',
            comment: 'Comentário 1'
        }, {
            nickname: 'nick com 2',
            comment: 'Comentário 2'
        }]
    }, {
        id: Math.random(),
        nickname: 'Nickname 2',
        email: 'email 2',
        image: require('../../../assets/imgs/bw.jpg'),
        comments: []
    }],
    // isUploading: false,
}

const reducer = (state = initialState, action) => {
    switch (action.type) {
        case ADD_POST:
            return {
                ...state,
                posts: state.posts.concat({
                    ...action.payload
                })
            }
        // case SET_POSTS:
        //     return {
        //         ...state,
        //         posts: action.payload
        //     }
        case ADD_COMMENT:
            return {
                ...state,
                posts: state.posts.map(post => {
                    if (post.id === action.payload.postId) {
                        if (post.comments) {
                            post.comments = post.comments.concat(
                                action.payload.comment
                            )
                        } else {
                            post.comments = [action.payload.comment]
                        }
                    }
                    return post
                })
            }
        // case CREATING_POST:
        //     return {
        //         ...state,
        //         isUploading: true
        //     }
        // case POST_CREATED:
        //     return {
        //         ...state,
        //         isUploading: false
        //     }
        default:
            return state
    }
}

export default reducer