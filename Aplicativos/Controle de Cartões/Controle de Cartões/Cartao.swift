//
//  Cartao.swift
//  Controle de Cartões
//
//  Created by Daniel Dallagnese on 14/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class Cartao {
    var nomeCartao: String
    var venctoFatura: Date
    var valorFatura: Float
    
    init(nomeCartao: String, venctoFatura: Date, valorFatura: Float) {
        self.nomeCartao = nomeCartao
        self.venctoFatura = venctoFatura
        self.valorFatura = valorFatura
    }
}

