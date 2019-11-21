//
//  SnapsViewController.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 07/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SnapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let textoSemSnaps = "Nenhum Snap para visualizar"
    
    var snaps: [Snap] = []
    
    @IBAction func sair(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        }catch{
            let alerta = Alerta(titulo: "Erro ao sair", mensagem: "Ocorreu um erro ao finalizar a sessão do usuário")
            self.present(alerta.getAlerta(), animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let idUsuarioLogado = Auth.auth().currentUser?.uid {
            let usuarios = Database.database().reference().child("usuarios")
            let snaps = usuarios.child(idUsuarioLogado).child("snaps")
            // Cria listener para snaps adicionados
            snaps.observe(DataEventType.childAdded, with: { (snapshot) in
                let dados = snapshot.value as! NSDictionary
                
                let snap = Snap()
                snap.idSnap = snapshot.key
                snap.de = dados["de"] as! String
                snap.nome = dados["nome"] as! String
                snap.descricao = dados["descricao"] as! String
                snap.urlImagem = dados["urlImagem"] as! String
                snap.idImagem = dados["idImagem"] as! String
                
                self.snaps.append(snap)
                
                self.tableView.reloadData()
            })
            
            // Cria listener para snaps removidos
            snaps.observe(DataEventType.childRemoved, with: { (snapshot) in
                var indice = 0
                for snap in self.snaps {
                    if snap.idSnap == snapshot.key {
                        self.snaps.remove(at: indice)
                    }
                    indice += 1
                }
                self.tableView.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if snaps.count == 0 {
            return 1
        }else{
            return snaps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaSnap", for: indexPath)
        
        // Configure the cell...
        let qtdeSnaps = snaps.count
        if qtdeSnaps == 0 {
            celula.textLabel?.text = textoSemSnaps
            celula.detailTextLabel?.text = ""
        }else{
            celula.textLabel?.text = snaps[indexPath.row].nome
            celula.detailTextLabel?.text = snaps[indexPath.row].descricao
        }
        
        return celula
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if snaps.count > 0 {
            self.performSegue(withIdentifier: "detalhesSnapSegue", sender: self.snaps[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detalhesSnapSegue" {
            let detalhesSnapViewController = segue.destination as! DetalhesSnapViewController
            detalhesSnapViewController.snap = sender as! Snap
        }
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
