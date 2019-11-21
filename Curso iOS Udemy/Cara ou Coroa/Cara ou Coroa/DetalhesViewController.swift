//
//  DetalhesViewController.swift
//  Cara ou Coroa
//
//  Created by Daniel Dallagnese on 15/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import Foundation

import UIKit

class DetalhesViewController: UIViewController {
    
    var numeroRandomicoRecebido: Int!
    
    @IBOutlet weak var moedaImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if numeroRandomicoRecebido == 0 {
            // Cara
            moedaImageView.image = #imageLiteral(resourceName: "moeda_cara")
        }
        else {
            // Coroa
            moedaImageView.image = #imageLiteral(resourceName: "moeda_coroa")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

