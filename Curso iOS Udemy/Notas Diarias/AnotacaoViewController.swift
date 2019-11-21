//
//  AnotacaoViewController.swift
//  Notas Diarias
//
//  Created by Daniel Dallagnese on 03/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import CoreData

class AnotacaoViewController: UIViewController {

    @IBOutlet weak var texto: UITextView!
    var gerenciadorObjetos: NSManagedObjectContext!
    var anotacao: NSManagedObject!
    
    @IBAction func salvarAnotacao(_ sender: Any) {
        
        if anotacao != nil {
            // Atualizar
            atualizar()
        }else{
            // Incluir
            salvar()
        }
        
        // Retornar para a tela inicial
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func atualizar() {
        anotacao.setValue(self.texto.text, forKey: "texto")
        anotacao.setValue(NSDate(), forKey: "data")
    
        do {
            try gerenciadorObjetos.save()
            print("Atualizou")
        }catch let erro as NSError {
            print("Erro ao atualizar anotação: "+erro.description)
        }
    }
    
    func salvar() {
        let novaAnotacao = NSEntityDescription.insertNewObject(forEntityName: "Anotacao", into: gerenciadorObjetos)
        
        // Definir dados da anotação
        novaAnotacao.setValue(self.texto.text, forKey: "texto")
        novaAnotacao.setValue(NSDate(), forKey: "data")
        
        do {
            try gerenciadorObjetos.save()
            print("Salvou")
        }catch let erro as NSError {
            print("Erro ao salvar anotação: "+erro.description)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        gerenciadorObjetos = appDelegate.persistentContainer.viewContext
        
        // Selecionar o campo texto para abrir o teclado
        self.texto.becomeFirstResponder()
        
        //
        if anotacao != nil {
            // Atualizar
            self.texto.text = anotacao.value(forKey: "texto") as! String
        }else{
            // Incluir
            self.texto.text = ""
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
