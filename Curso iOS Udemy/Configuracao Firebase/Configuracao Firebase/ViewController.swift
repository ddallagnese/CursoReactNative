//
//  ViewController.swift
//  Configuracao Firebase
//
//  Created by Daniel Dallagnese on 06/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var pontuacao: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let usuario = Auth.auth()
        
//        do {
//            try usuario.signOut()
//        }catch{
//            print("Erro ao desconectar")
//        }
        
        usuario.signIn(withEmail: "dallagnese@gmail.com", password: "daniel") { (usuario, erro) in
            if erro == nil {
                print("Login realizado "+String(describing: usuario?.email))
            }else{
                print("Erro ao fazer login: "+String(describing: erro?.localizedDescription))
            }
        }
    
        usuario.addStateDidChangeListener { (autenticacao, usuario) in
            if let usuarioLogado = usuario {
                print("Usuário logado "+String(describing: usuarioLogado.email))
            }else{
                print("Usuário desconectado")
            }
        }
        
        
        
//        usuario.createUser(withEmail: "dallagnese@gmail.com", password: "daniel") { (usuario, erro) in
//            if erro == nil {
//                print("Usuário criado "+String(describing: usuario?.email))
//            }else{
//                print("Erro ao criar usuário: "+String(describing: erro?.localizedDescription))
//            }
//        }
        
//        let database = Database.database().reference()
//        
//        let pontuacao = database.child("pontuacao")
//        
//        pontuacao.observe(DataEventType.value, with: { (dados) in
//            self.pontuacao.text = String(describing: dados.value!)
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

