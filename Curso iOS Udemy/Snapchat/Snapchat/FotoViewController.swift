//
//  FotoViewController.swift
//  Snapchat
//
//  Created by Daniel Dallagnese on 07/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseStorage

class FotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imagemIV: UIImageView!
    @IBOutlet weak var descricaoTF: UITextField!
    @IBOutlet weak var proximoB: UIButton!
    
    var imagePicker = UIImagePickerController()
    var idImagem = NSUUID().uuidString
    
    @IBAction func selecionarFoto(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func abrirCamera(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func proximo(_ sender: Any) {
        self.proximoB.setTitle("Carregando...", for: .normal)
        self.proximoB.isEnabled = false
        
        let armazenamento = Storage.storage().reference()
        let imagens = armazenamento.child("imagens")
        
        // Recuperar imagem
        if let imagemDados = UIImageJPEGRepresentation(imagemIV.image!, 0.5) {// 0.5 é a qualidade da imagem, de 0 (pior) até 1 (melhor)
            imagens.child("\(self.idImagem).jpg").putData(imagemDados, metadata: nil, completion: { (metaDados, erro) in
                if erro == nil {
                    self.performSegue(withIdentifier: "selecionarUsuarioSegue", sender: metaDados?.downloadURL()?.absoluteString)
                }else{
                    let alerta = Alerta(titulo: "Upload falhou", mensagem: "Erro ao salvar a foto, tente novamente")
                    self.present(alerta.getAlerta(), animated: true, completion: nil)
                }
                self.proximoB.setTitle("Próximo", for: .normal)
                self.proximoB.isEnabled = true
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selecionarUsuarioSegue" {
            let usuarioViewController = segue.destination as! UsuariosTableViewController
            usuarioViewController.descricao = self.descricaoTF.text!
            usuarioViewController.urlImagem = sender as! String
            usuarioViewController.idImagem = self.idImagem
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagemIV.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        imagePicker.dismiss(animated: true, completion: nil)
        self.proximoB.isEnabled = true
        self.proximoB.backgroundColor = UIColor(red: 0.553, green: 0.369, blue: 0.749, alpha: 1) // alpha é a opacidade, de 0 (transparente) até 1 (sólida)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        proximoB.isEnabled = false
        proximoB.backgroundColor = UIColor.lightGray
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
