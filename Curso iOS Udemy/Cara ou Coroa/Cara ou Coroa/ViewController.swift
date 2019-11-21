//
//  ViewController.swift
//  Cara ou Coroa
//
//  Created by Daniel Dallagnese on 15/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jogarMoeda" {
            let numeroRandomico = arc4random_uniform(2)
            let viewControllerDestino = segue.destination as! DetalhesViewController
            
            viewControllerDestino.numeroRandomicoRecebido = Int(numeroRandomico)
        }
    }


}

