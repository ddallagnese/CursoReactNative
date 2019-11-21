//
//  CadastroViewController.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 06/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CadastroViewController: UIViewController {


    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nomeTF: UITextField!
    @IBOutlet weak var senhaTF: UITextField!
    @IBOutlet weak var confirmaSenhaTF: UITextField!
    
    @IBAction func criarConta(_ sender: Any) {
        if let email = self.emailTF.text {
            if let nome = self.nomeTF.text {
                if let senha = self.senhaTF.text {
                    if let confirmaSenha = self.confirmaSenhaTF.text {
                        // Validar senha
                        if senha == confirmaSenha {
                            if nome != "" {
                                // Criar nova conta no Firebase
                                Auth.auth().createUser(withEmail: email, password: senha, completion: { (usuarioCriado, erroRetornado) in
                                    if erroRetornado == nil {
                                        if usuarioCriado == nil {
                                            let alerta = Alerta(titulo: "Erro ao criar usuário", mensagem: "Houve um erro ao realizar a criação do usuário, tente novamente")
                                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                                        }else{
                                            let database = Database.database().reference()
                                            let usuarios = database.child("usuarios")
                                            let usuarioDados = ["nome": nome, "email": email]
                                            usuarios.child(usuarioCriado!.uid).setValue(usuarioDados)
                                            
                                            self.performSegue(withIdentifier: "cadastroLoginSegue", sender: nil)
                                        }
                                    }else{
                                        let erro = erroRetornado! as NSError
                                        if let codigoErro = erro.userInfo["error_name"] {
                                            let erroTexto = codigoErro as! String
                                            var mensagemErro = ""
                                            switch erroTexto {
                                            case "ERROR_INVALID_EMAIL":
                                                mensagemErro = "O endereço de e-mail digitado não é um endereço válido."
                                                break
                                            case "ERROR_WEAK_PASSWORD":
                                                mensagemErro = "A senha precisa ter ao menos 6 caracteres, e precisa ter letras e números."
                                                break
                                            case "ERROR_EMAIL_ALREADY_IN_USE":
                                                mensagemErro = "Este endereço de e-mail já está sendo utilizado."
                                                break
                                            default:
                                                mensagemErro = "Os dados digitados estão incorretos."
                                            }
                                            let alerta = Alerta(titulo: "Erro ao criar conta", mensagem: mensagemErro)
                                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                                        }
                                    }
                                })
                                
                            }else{
                                let alerta = Alerta(titulo: "Nome não preenchido", mensagem: "Digite o seu nome para criar a conta de usuário.")
                                self.present(alerta.getAlerta(), animated: true, completion: nil)
                            }
                        }else{
                            let alerta = Alerta(titulo: "Senhas Incorretas", mensagem: "A senha e a confirmação precisam ser iguais. Verifique.")
                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                        } // Fim validar senha
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
