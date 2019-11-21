//
//  ViewController.swift
//  Idade de Cachorro
//
//  Created by Daniel Dallagnese on 15/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBOutlet weak var campoIdadeCachorro: UITextField!
    @IBOutlet weak var legendaResultado: UILabel!
    
    @IBAction func calcular(_ sender: AnyObject) {
        var idadeCachorro = Int(campoIdadeCachorro.text!)!
        if idadeCachorro == 1 {
            idadeCachorro = 5
        }
        else {
            idadeCachorro = ((idadeCachorro - 1) * 4) + 5
        }
        legendaResultado.text = "A idade do cachorro é " + String(idadeCachorro)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

