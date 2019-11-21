//
//  ResultadoBateria.swift
//  Kart
//
//  Created by Daniel Dallagnese on 16/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ResultadoBateria {
    var posicao: String!
    var piloto: String!
    var pontos: Int!
    
    init(posicao: String, piloto: String, pontos: Int) {
        self.posicao = posicao
        self.piloto = piloto
        self.pontos = pontos
    }
}
