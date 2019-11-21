//
//  ViewController.swift
//  Gerador Numeros
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
    @IBOutlet weak var legendaResultado: UILabel!
    @IBAction func gerarNumero(_ sender: AnyObject) {
        var numeroAleatorio = arc4random_uniform(10)
        legendaResultado.text = String(numeroAleatorio)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

