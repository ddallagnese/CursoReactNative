//
//  ViewController.swift
//  Salvar Dados
//
//  Created by Daniel Dallagnese on 17/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //UserDefaults.standard.set("azul", forKey: "corFundo")
        
        //let texto = UserDefaults.standard.object(forKey: "corFundo")
        //print(texto)
        
        //var array:[String] = ["Lasanha","Pizza","Torta"]
        //UserDefaults.standard.set(array, forKey: "comidas")
        
        UserDefaults.standard.removeObject(forKey: "comidas")
        
        let arrayRecuperado = UserDefaults.standard.object(forKey: "comidas")
        print(arrayRecuperado)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

