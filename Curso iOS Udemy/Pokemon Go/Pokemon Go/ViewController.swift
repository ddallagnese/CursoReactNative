//
//  ViewController.swift
//  Pokemon Go
//
//  Created by Daniel Dallagnese on 04/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    
    var gerenciadorLocalizacao = CLLocationManager()
    var coreDataPokemon: CoreDataPokemon!
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapa.delegate = self
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
        // Recuperar os Pokemons
        self.coreDataPokemon = CoreDataPokemon()
        self.pokemons = self.coreDataPokemon.recuperarTodosPokemons()
        
        // Exibir pokémons
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            
            if let coordenadas = self.gerenciadorLocalizacao.location?.coordinate {
                
                let indicePokemonAleatorio = arc4random_uniform(UInt32(self.pokemons.count))
                let pokemon = self.pokemons[Int(indicePokemonAleatorio)]
                
                let anotacao = PokemonAnotacao(coordenadas: coordenadas, pokemon: pokemon)
                
                // Gerar números aleatórios entre -0.002 e +0.002 para posicionar o pokémon
                anotacao.coordinate.latitude += (Double(arc4random_uniform(400)) - 200) / 100000
                anotacao.coordinate.longitude += (Double(arc4random_uniform(400)) - 200) / 100000
                
                self.mapa.addAnnotation(anotacao)
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Substituir os alfinetes por imagens
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let anotacaoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        if annotation is MKUserLocation {
            anotacaoView.image = #imageLiteral(resourceName: "player")
        }else{
            let pokemon = (annotation as! PokemonAnotacao).pokemon
            anotacaoView.image = UIImage(named: pokemon.nomeImagem!)
        }
        
        var frame = anotacaoView.frame
        frame.size.height = 40
        frame.size.width = 40
        
        anotacaoView.frame = frame
        
        return anotacaoView
    }
    
    // MARK: Verificar se pressionou em algum Pokémon
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let anotacao = view.annotation
        mapView.deselectAnnotation(anotacao, animated: true)
        
        let pokemon = (anotacao as! PokemonAnotacao).pokemon

        if anotacao is MKUserLocation {
            return
        }
        
        if let coordAnotacao = anotacao?.coordinate {
            let regiao = MKCoordinateRegionMakeWithDistance(coordAnotacao, 100, 100)
            mapa.setRegion(regiao, animated: true)
            gerenciadorLocalizacao.stopUpdatingLocation()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            if let coord = self.gerenciadorLocalizacao.location?.coordinate {
                if MKMapRectContainsPoint(self.mapa.visibleMapRect, MKMapPointForCoordinate(coord)) {
                    self.coreDataPokemon.salvarPokemon(pokemon: pokemon)
                    self.mapa.removeAnnotation(anotacao!)
                    
                    let alertController = UIAlertController(title: "Capturou!",
                                                            message: "Capturou o pokémon \(pokemon.nome!)",
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "Muito distante",
                                                            message: "O pokémon \(pokemon.nome!) está muito distante. Aproxime-se mais para poder capturá-lo",
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    // MARK: Método para atualização da localização no mapa
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.centralizar()
    }
    
    // MARK: Método para exibir alerta caso o usuário não tenha permitido acesso à localização
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Verifica se o usuário negou a autorização para uso da localização, e abre as configurações do aparelho para liberar
        if status != .authorizedWhenInUse && status != .notDetermined {
            let alertaController = UIAlertController(title: "Permissão de localização",
                                                     message: "Permita o acesso à sua localização para poder caçar pokémons.",
                                                     preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir Configurações", style: .default, handler: { (alertaConfiguracoes) in
                if let configuracoes = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(configuracoes as URL)
                }
            })
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present(alertaController, animated: true, completion: nil)
        }
    }
    
    //MARK: Ação dos botões
    func centralizar() {
        if let coordenadas = gerenciadorLocalizacao.location?.coordinate {
            let regiao = MKCoordinateRegionMakeWithDistance(coordenadas, 200, 200)
            mapa.setRegion(regiao, animated: true)
            gerenciadorLocalizacao.stopUpdatingLocation()
        }
    }
    
    @IBAction func centralizarJogador(_ sender: Any) {
        self.centralizar()
    }

    @IBAction func abrirPokedex(_ sender: Any) {
    }


}

