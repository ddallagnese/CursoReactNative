//
//  Alerta.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 11/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class Alerta {
    var titulo: String
    var mensagem: String
    
    init(titulo: String, mensagem: String) {
        self.titulo = titulo
        self.mensagem = mensagem
    }
    
    func getAlerta() -> UIAlertController {
        let alerta = UIAlertController(title: titulo, message: mensagem, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        return alerta
    }
}
