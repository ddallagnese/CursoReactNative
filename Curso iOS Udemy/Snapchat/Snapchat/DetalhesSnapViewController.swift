//
//  DetalhesSnapViewController.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 12/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DetalhesSnapViewController: UIViewController {

    @IBOutlet weak var imagemIV: UIImageView!
    @IBOutlet weak var descricaoTF: UILabel!
    @IBOutlet weak var contadorTF: UILabel!
    
    var snap = Snap()
    
    var tempo = 11
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descricaoTF.text = "Carregando..."
        
        imagemIV.sd_setImage(with: URL(string: snap.urlImagem)) { (imagem, erro, cache, url) in
            if erro == nil {
                self.descricaoTF.text = self.snap.descricao
                // Inicializar o timer
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    // Decrementar o tempo
                    self.tempo -= 1
                    
                    // Exibir na tela
                    self.contadorTF.text = String(self.tempo)
                    
                    // Finalizar a execução do timer
                    if self.tempo == 0 {
                        timer.invalidate()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let idUsuarioLogado = Auth.auth().currentUser?.uid {
            // Remover do banco de dados
            let usuarios = Database.database().reference().child("usuarios")
            let snaps = usuarios.child(idUsuarioLogado).child("snaps")
            snaps.child(snap.idSnap).removeValue()
            
            // Remover imagem do storage
            let imagens = Storage.storage().reference().child("imagens")
            imagens.child("\(snap.idImagem).jpg").delete(completion: { (erro) in
                if erro == nil {
//                    print("Sucesso")
                }else{
//                    print("Erro")
                }
            })
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
