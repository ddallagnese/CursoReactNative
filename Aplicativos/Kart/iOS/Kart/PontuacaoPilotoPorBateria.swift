//
//  PontuacaoPilotoPorBateria.swift
//  Kart
//
//  Created by Daniel Dallagnese on 18/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class PontuacaoPilotoPorBateria {
    var piloto: String
    var pontuacao: [Int]
    
    init(piloto: String, pontuacao: [Int]) {
        self.piloto = piloto
        self.pontuacao = pontuacao
    }
}
