//
//  Filme.swift
//  Filmes
//
//  Created by Daniel Dallagnese on 16/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class Filme {
    var titulo: String!
    var descricao: String!
    var imagem: UIImage!
    
    init(titulo:String, descricao:String, imagem:UIImage) {
        self.titulo = titulo
        self.descricao = descricao
        self.imagem = imagem
    }
}
