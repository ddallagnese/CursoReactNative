import React, {Component} from 'react';
import Header from './src/components/Header';
import { View } from 'react-native'
import Post from './src/components/Post';

export default class App extends Component {
    render() {
        const comments = [{
            nickname: 'Joana',
            comment: 'Muito bom'
        },{
            nickname: 'Marcio',
            comment: 'Pra que isso?'
        }]
        return (
            <View style={{ flex: 1 }}>
                <Header />
                <Post image={require('./assets/imgs/fence.jpg')}
                    comments={comments} />
            </View>
        );
    }
}
