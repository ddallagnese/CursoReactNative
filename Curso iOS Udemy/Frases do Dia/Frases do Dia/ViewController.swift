//
//  ViewController.swift
//  Frases do Dia
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

    @IBOutlet weak var fraseDoDia: UILabel!
    @IBAction func novaFrase(_ sender: AnyObject) {
        var frasesDoDia: [String] = []
        frasesDoDia.append("Frase 1")
        frasesDoDia.append("Frase 2")
        frasesDoDia.append("Frase 3")
        frasesDoDia.append("Frase 4")
        frasesDoDia.append("Frase 5")
        frasesDoDia.append("Frase 6")
        frasesDoDia.append("Frase 7")
        frasesDoDia.append("Frase 8")
        frasesDoDia.append("Frase 9")
        frasesDoDia.append("Frase 10")
        
        fraseDoDia.text = frasesDoDia[Int(arc4random_uniform(10))]

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

