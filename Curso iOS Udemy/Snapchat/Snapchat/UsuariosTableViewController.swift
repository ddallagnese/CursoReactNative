//
//  UsuariosTableViewController.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 12/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UsuariosTableViewController: UITableViewController {

    var usuarios: [Usuario] = []
    var descricao = ""
    var urlImagem = ""
    var idImagem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usuarios = Database.database().reference().child("usuarios")
        
        usuarios.observe(DataEventType.childAdded, with: { (snapchat) in
            let dados = snapchat.value as? NSDictionary
            
            // Recupera id do usuário logado
            let idUsuarioLogado = Auth.auth().currentUser?.uid
            
            let emailUsuario = dados?["email"] as! String
            let nomeUsuario = dados?["nome"] as! String
            let idUsuario = snapchat.key
            
            let usuario = Usuario(email: emailUsuario, nome: nomeUsuario, id: idUsuario)
            
            if idUsuarioLogado != idUsuario {
                self.usuarios.append(usuario)
            }
            self.tableView.reloadData()
        })
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
        return self.usuarios.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath)

        // Configure the cell...
        celula.textLabel?.text = self.usuarios[indexPath.row].nome
        celula.detailTextLabel?.text = self.usuarios[indexPath.row].email

        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Identifica a célula selecionada
        let usuarioSelecionado = self.usuarios[indexPath.row]
        let idUsuarioSelecionado = usuarioSelecionado.id
        
        // Recupera referência do banco de dados
        let usuarios = Database.database().reference().child("usuarios")
        let snaps = usuarios.child(idUsuarioSelecionado).child("snaps")
        
        // Recupera dados do usuário logado
        if let idUsuarioLogado = Auth.auth().currentUser?.uid {
            let usuarioLogado = usuarios.child(idUsuarioLogado)
            usuarioLogado.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let dados = snapshot.value as! NSDictionary

                // Define o snap a enviar
                let snap = [
                    "de": dados["email"] as! String,
                    "nome": dados["nome"] as! String,
                    "descricao": self.descricao,
                    "urlImagem": self.urlImagem,
                    "idImagem": self.idImagem
                ]
                snaps.childByAutoId().setValue(snap)
                
                self.navigationController?.popToRootViewController(animated: true)
            })
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
