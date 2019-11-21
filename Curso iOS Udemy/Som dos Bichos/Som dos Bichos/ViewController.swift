//
//  ViewController.swift
//  Som dos Bichos
//
//  Created by Daniel Dallagnese on 12/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func reproduzir (som: String) {
        if let caminhoSom = Bundle.main.path(forResource: som, ofType: "mp3") {
            let url = URL(fileURLWithPath: caminhoSom)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.play()
            }catch{
                print("Erro ao executar o som")
            }
            
        }
    }
    
    @IBAction func cachorro(_ sender: Any) {
        reproduzir(som: "cao")
    }

    @IBAction func gato(_ sender: Any) {
        reproduzir(som: "gato")
    }
    
    @IBAction func leao(_ sender: Any) {
        reproduzir(som: "leao")
    }
    
    @IBAction func macaco(_ sender: Any) {
        reproduzir(som: "macaco")
    }
    
    @IBAction func ovelha(_ sender: Any) {
        reproduzir(som: "ovelha")
    }
    
    @IBAction func vaca(_ sender: Any) {
        reproduzir(som: "vaca")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

