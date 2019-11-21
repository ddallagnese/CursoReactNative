//
//  Usuario.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 12/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class Usuario {
    var email: String
    var nome: String
    var id: String
    
    init(email: String, nome: String, id: String) {
        self.email = email
        self.nome = nome
        self.id = id
    }
}
