//
//  Bateria.swift
//  Kart
//
//  Created by Daniel Dallagnese on 14/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class Bateria {
    var numero: String!
    var data: String!
    var hora: String!
    var local: String!
    var cidade: String!
    var resultados: [ResultadoBateria]
    var extras: [ResultadoBateria]
    
    init(numero: String, data: String, hora: String, local: String, cidade: String, resultados: [ResultadoBateria], extras: [ResultadoBateria]) {
        self.numero = numero
        self.data = data
        self.hora = hora
        self.local = local
        self.cidade = cidade
        self.resultados = resultados
        self.extras = extras
    }
}
