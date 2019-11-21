//
//  ViewController.swift
//  projetorose
//
//  Created by Daniel Dallagnese on 25/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       }

    @IBOutlet weak var IdadeCachorro: UITextField!
    @IBOutlet weak var resultadoIdade: UILabel!
    
    @IBAction func calcularIdade(_ sender: AnyObject) {
        
        var vIdadeCachorro = Int(IdadeCachorro.text!)!
        
        vIdadeCachorro = vIdadeCachorro * 7
        
        resultadoIdade.text="A idade calculada é "+String(vIdadeCachorro)+" na idade Humana"
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

