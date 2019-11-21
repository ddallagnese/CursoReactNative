//
//  DetalhesViewController.swift
//  Passando dados entre views
//
//  Created by Daniel Dallagnese on 15/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import Foundation

import UIKit

class DetalhesViewController: UIViewController {
    
    @IBOutlet weak var resultadoLabel2: UILabel!
    var textoRecebido:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        resultadoLabel2.text = textoRecebido
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

