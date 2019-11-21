//: Playground - noun: a place where people can play

import UIKit

class Animal {
    var cor = "marrom"
    func dormir() -> String {
        return "dormindo"
    }
}

class Cachorro:Animal {
    func latir() -> String {
        return "latindo"
    }
}

class Passaro:Animal {
    func voar() -> String {
        return "voando"
    }
}

class Papagaio:Passaro {
    func repetir() -> String {
        return "repetindo"
    }
    
    override func dormir() -> String {
        return "dormindo papagaio"
    }
}

var cachorro = Cachorro()
cachorro.cor
cachorro.dormir()
cachorro.latir()

var passaro = Passaro()
passaro.cor
passaro.dormir()
passaro.voar()

var papagaio = Papagaio()
papagaio.repetir()
papagaio.dormir()