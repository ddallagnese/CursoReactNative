//
//  ViewController.swift
//  Minhas Notas
//
//  Created by Daniel Dallagnese on 17/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let notaDigitadaChave: String = "notaDigitada"
    @IBOutlet weak var notaDigitada: UITextView!
    
    @IBAction func salvarNotas(_ sender: AnyObject) {
        if let texto = notaDigitada.text {
            self.salvarDadosNota(texto: texto)
        }
    }
    
    func salvarDadosNota (texto: String) {
        UserDefaults.standard.set(texto, forKey: notaDigitadaChave)
        esconderTeclado()
    }
    
    func recuperarDadosNota () -> String {
        let textoRecuperado = UserDefaults.standard.object(forKey: notaDigitadaChave)
        if textoRecuperado != nil {
            return textoRecuperado as! String
        }
        else {
            return ""
        }
    }
    
    func esconderTeclado() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notaDigitada.text = self.recuperarDadosNota()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        esconderTeclado()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

