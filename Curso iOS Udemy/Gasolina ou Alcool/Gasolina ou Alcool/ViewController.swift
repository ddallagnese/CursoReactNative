//
//  ViewController.swift
//  Gasolina ou Alcool
//
//  Created by Daniel Dallagnese on 15/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var precoAlcoolTextField: UITextField!
    @IBOutlet weak var precoGasolinaTextField: UITextField!
    @IBOutlet weak var resultadoLabel: UILabel!
    @IBAction func calcularCombustivel(_ sender: AnyObject) {
        
        var precoAlcool:Double = 0
        var precoGasolina:Double = 0
        var resultadoPreco:Double = 0
        
        if let resultadoAlcool = precoAlcoolTextField.text {
            if resultadoAlcool != "" {
                if let resultadoNumero = Double(resultadoAlcool) {
                    precoAlcool = resultadoNumero
                }
            }
        }

        if let resultadoGasolina = precoGasolinaTextField.text {
            if resultadoGasolina != "" {
                if let resultadoNumero = Double(resultadoGasolina) {
                    precoGasolina = resultadoNumero
                }
            }
        }
        
        resultadoPreco = precoAlcool / precoGasolina
        if resultadoPreco >= 0.7 {
            resultadoLabel.text = "Melhor utilizar Gasolina!"
        }
        else {
            resultadoLabel.text = "Melhor utilizar Álcool!"
        }
        
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

