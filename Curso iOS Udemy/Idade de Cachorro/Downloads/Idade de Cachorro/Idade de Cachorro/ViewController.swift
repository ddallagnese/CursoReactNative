//
//  ViewController.swift
//  Idade de Cachorro
//
//  Created by Jamilton  Damasceno on 06/07/16.
//  Copyright © 2016 Jamilton  Damasceno. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var idadeCachorroText: UITextField!
    @IBOutlet weak var resultadoLabel: UILabel!
    
    @IBAction func descobrirIdade(_ sender: AnyObject) {
        
        var idadeCachorro = Int(idadeCachorroText.text!)!
        idadeCachorro = idadeCachorro * 7
        resultadoLabel.text = "A idade do cachorro é " + String(idadeCachorro)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

