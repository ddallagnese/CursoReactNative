import { Alert, Platform } from 'react-native'

const server = Platform.OS === 'ios' ?
    'postgresql://localhost' : 'http://10.0.2.2:3000'

function showError(err) {
    Alert.alert('Ops! Ocorreu um Problema!', `Mensagem: ${err}`)
}

export { server, showError }