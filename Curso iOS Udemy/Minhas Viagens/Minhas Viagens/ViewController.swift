//
//  ViewController.swift
//  Minhas Viagens
//
//  Created by Daniel Dallagnese on 28/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    var viagem: Dictionary<String, String> = [:]
    var indiceSelecionado: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(indiceSelecionado)
        if let indice = indiceSelecionado {
            if indice == -1 { // adicionar
                configuraGerenciadorLocalizacao()
            }else{ // listar
                exibirAnotacao(viagem: viagem)
            }
        }
        
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.marcar(gesture:)))
        reconhecedorGesto.minimumPressDuration = 2
        mapa.addGestureRecognizer(reconhecedorGesto)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let local = locations.last!

        // exibir local
        let deltaLat: CLLocationDegrees = 0.01
        let deltaLon: CLLocationDegrees = 0.01
        
        let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2DMake(local.coordinate.latitude, local.coordinate.longitude)
        
        let areaExibicao: MKCoordinateSpan = MKCoordinateSpanMake(deltaLat, deltaLon)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegionMake(localizacao, areaExibicao)
        
        self.mapa.setRegion(regiao, animated: true)

    }
    
    func exibirLocal(latitude: Double, longitude: Double) {
        // exibir local
        let deltaLat: CLLocationDegrees = 0.01
        let deltaLon: CLLocationDegrees = 0.01
        
        let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let areaExibicao: MKCoordinateSpan = MKCoordinateSpanMake(deltaLat, deltaLon)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegionMake(localizacao, areaExibicao)
        
        self.mapa.setRegion(regiao, animated: true)
    }
    
    func exibirAnotacao(viagem: Dictionary<String, String>) {
        // Exibir anotação com dados de endereço
        if let localViagem = viagem["local"] {
            if let latitudeS = viagem["latitude"] {
                if let longitudeS = viagem["longitude"] {
                    if let latitude = Double(latitudeS) {
                        if let longitude = Double(longitudeS) {
                            exibirLocal(latitude: latitude, longitude: longitude)

                            // exibir anotação
                            let anotacao = MKPointAnnotation()
                            anotacao.coordinate.latitude = latitude
                            anotacao.coordinate.longitude = longitude
                            anotacao.title = localViagem
                            
                            self.mapa.addAnnotation(anotacao)
                        }
                    }
                }
            }
        }
    }
    
    func marcar(gesture: UIGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.began {
            // Recupera as coordenadas do ponto selecionado
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert(pontoSelecionado, toCoordinateFrom: self.mapa)
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            // Recupera endereço do ponto selecionado
            var localCompleto = "Endereço não encontrado"
            CLGeocoder().reverseGeocodeLocation(localizacao) { (detalhesLocal, erro) in
                if erro == nil {
                    
                    if let dadosLocal = detalhesLocal?.first {
                        
                        if let nome = dadosLocal.name {
                            localCompleto = nome
                        }else{
                            if let endereco = dadosLocal.thoroughfare {
                                localCompleto = endereco
                            }
                        }
                        
                        /*var endNomeLocal = ""
                        if dadosLocal.name != nil {
                            endNomeLocal = (dadosLocal.name)!
                        }
                        var endRua = ""
                        if dadosLocal.thoroughfare != nil {
                            endRua = (dadosLocal.thoroughfare)!
                        }
                        var endNumero = ""
                        if dadosLocal.subThoroughfare != nil {
                            endNumero = (dadosLocal.subThoroughfare)!
                        }
                        var endCidade = ""
                        if dadosLocal.locality != nil {
                            endCidade = (dadosLocal.locality)!
                        }
                        var endBairro = ""
                        if dadosLocal.subLocality != nil {
                            endBairro = (dadosLocal.subLocality)!
                        }
                        var endCep = ""
                        if dadosLocal.postalCode != nil {
                            endCep = (dadosLocal.postalCode)!
                        }
                        var endPais = ""
                        if dadosLocal.country != nil {
                            endPais = (dadosLocal.country)!
                        }
                        var endEstado = ""
                        if dadosLocal.administrativeArea != nil {
                            endEstado = (dadosLocal.administrativeArea)!
                        }
                        var endSubEstado = ""
                        if dadosLocal.subAdministrativeArea != nil {
                            endSubEstado = (dadosLocal.subAdministrativeArea)!
                        }*/
                        
                        // Salvar dados no dispositivo
                        self.viagem = ["local": localCompleto, "latitude": String(coordenadas.latitude), "longitude": String(coordenadas.longitude)]
                        ArmazenamentoDados().salvarViagem(viagem: self.viagem)
                        
                        self.exibirAnotacao(viagem: self.viagem)
                        
                    }
                    
                }else{
                    print(erro)
                }
            }
            
        }
    }
    
    func configuraGerenciadorLocalizacao(){
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Caso o usuário não tenha permitido acesso à localização, exibe alerta para abrir a tela de configurações
        if status != .authorizedWhenInUse {
            let alertaController = UIAlertController(title: "Permissão de localização",
                                                     message: "Necessário permissão para acesso à sua localização",
                                                     preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir configurações", style: .default, handler: { (alertaConfiguracoes) in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

