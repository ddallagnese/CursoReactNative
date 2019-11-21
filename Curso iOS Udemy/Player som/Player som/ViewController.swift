//
//  ViewController.swift
//  Player som
//
//  Created by Daniel Dallagnese on 12/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player = AVAudioPlayer()
    
    @IBOutlet weak var volume: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let caminhoMusica = Bundle.main.path(forResource: "bach", ofType: "mp3") {
            let url = URL(fileURLWithPath: caminhoMusica)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
            }catch{
                print("Erro ao executar o som")
            }
            
        }
        
    }
    
    @IBAction func atualizarVolume(_ sender: Any) {
        player.volume = volume.value
    }
    
    @IBAction func play(_ sender: Any) {
        player.play()
    }
    
    @IBAction func pause(_ sender: Any) {
        player.pause()
    }
    
    @IBAction func stop(_ sender: Any) {
        player.stop()
        player.currentTime = 0
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

