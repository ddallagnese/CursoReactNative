//
//  EntrarViewController.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 06/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseAuth

class EntrarViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var senhaTF: UITextField!
    
    @IBAction func entrar(_ sender: Any) {
        if let email = self.emailTF.text {
            if let senha = self.senhaTF.text {
                // Autenticar o usuário no Firebase
                Auth.auth().signIn(withEmail: email, password: senha, completion: { (usuarioCriado, erroRetornado) in
                    if erroRetornado == nil {
                        if usuarioCriado == nil {
                            let alerta = Alerta(titulo: "Erro ao autenticar", mensagem: "Houve um erro ao realizar a autenticação, tente novamente")
                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                        }else{
                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
                        }
                    }else{
                        let alerta = Alerta(titulo: "Problema na autenticação", mensagem: "Não foi possível autenticar o usuário, verifique os dados informados.")
                        self.present(alerta.getAlerta(), animated: true, completion: nil)
                    }
                })
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
