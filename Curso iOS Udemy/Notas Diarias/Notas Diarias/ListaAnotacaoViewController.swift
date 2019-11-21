//
//  ListaAnotacaoViewController.swift
//  Notas Diarias
//
//  Created by Daniel Dallagnese on 03/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import CoreData

class ListaAnotacaoViewController: UITableViewController {
    
    var gerenciadorObjetos: NSManagedObjectContext!
    var anotacoes: [NSManagedObject] = []
    
    func recuperaAnotacoes() {
        // Recupera todas as anotações
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Anotacao")
        
        let ordenacao = NSSortDescriptor(key: "data", ascending: false)
        requisicao.sortDescriptors = [ordenacao]
        
        do {
            let anotacoesRecuperadas = try gerenciadorObjetos.fetch(requisicao)
            self.anotacoes = anotacoesRecuperadas as! [NSManagedObject]
            
            self.tableView.reloadData()
            
        }catch let erro as NSError {
            print("Erro ao listar anotações: \(erro.description)")
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let anotacao = self.anotacoes[indexPath.row]
            self.gerenciadorObjetos.delete(anotacao)
            self.anotacoes.remove(at: indexPath.row)
            
            do {
                try gerenciadorObjetos.save()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }catch let erro as NSError {
                print("Erro ao remover nota: \(erro.localizedDescription)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        gerenciadorObjetos = appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidAppear(_ animated: Bool) {
        recuperaAnotacoes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return anotacoes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath)
        
        let anotacao = self.anotacoes[indexPath.row]
        celula.textLabel?.text = anotacao.value(forKey: "texto") as? String
        
        let data = anotacao.value(forKey: "data")
        // Formatar a data
        let formatacaoData = DateFormatter()
        formatacaoData.dateFormat = "dd/MM/yyyy hh:mm"
        let novaData = formatacaoData.string(from: data as! Date)
        
        celula.detailTextLabel?.text = novaData

        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let anotacao = anotacoes[indexPath.row]
        self.performSegue(withIdentifier: "detalhesNota", sender: anotacao)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detalhesNota" {
            let viewControllerDestino = segue.destination as! AnotacaoViewController
            viewControllerDestino.anotacao = sender as? NSManagedObject
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
