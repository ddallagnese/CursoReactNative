//
//  PokemonAnotacao.swift
//  Pokemon Go
//
//  Created by Daniel Dallagnese on 05/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import MapKit

class PokemonAnotacao: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pokemon: Pokemon
    init(coordenadas: CLLocationCoordinate2D, pokemon: Pokemon) {
        self.coordinate = coordenadas
        self.pokemon = pokemon
    }
    
}
