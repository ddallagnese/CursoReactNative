import React, { Component } from 'react'
// import { connect } from 'react-redux'
import { StyleSheet, FlatList, View } from 'react-native'
import Header from '../components/Header'
import Post from '../components/Post'
// import { fetchPosts } from '../store/actions/posts'

class Feed extends Component {
    // componentDidMount = () => {
    //     this.props.onFetchPosts()
    // }

    state = {
        posts: [{
            id: Math.random(),
            nickname: 'Nickname',
            email: 'email',
            image: require('../../assets/imgs/fence.jpg'),
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
            image: require('../../assets/imgs/bw.jpg'),
            comments: []
        }]
    }

    render() {
        return (
            <View style={styles.container}>
                <Header />
                <FlatList
                    data={this.state.posts}
                    // data={this.props.posts}
                    keyExtractor={item => `${item.id}`}
                    renderItem={({ item }) =>
                        <Post key={item.id} {...item} />} />
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF'
    }
})

// export default Feed

// const mapStateToProps = ({ posts }) => {
//     return {
//         posts: posts.posts
//     }
// }

// const mapDispatchToProps = dispatch => {
//     return {
//         onFetchPosts: () => dispatch(fetchPosts())
//     }
// }

// export default connect(mapStateToProps, mapDispatchToProps)(Feed)
export default Feed