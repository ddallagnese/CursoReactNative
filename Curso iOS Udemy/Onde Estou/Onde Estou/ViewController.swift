//
//  ViewController.swift
//  Onde Estou
//
//  Created by Daniel Dallagnese on 19/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    
    @IBOutlet weak var velocidadeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var enderecoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let localizacaoUsuario = locations.last
        
        let longitude = localizacaoUsuario?.coordinate.longitude
        let latitude = localizacaoUsuario?.coordinate.latitude
        let velocidade = localizacaoUsuario?.speed
        
        longitudeLabel.text = String(describing: longitude!)
        latitudeLabel.text = String(describing: latitude!)
        
        if velocidade! > 0 {
            velocidadeLabel.text = String(describing: velocidade!)
        }else{
            velocidadeLabel.text = "0"
        }
        
        
        let deltaLat: CLLocationDegrees = 0.01
        let deltaLon: CLLocationDegrees = 0.01
        
        let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        let areaExibicao: MKCoordinateSpan = MKCoordinateSpanMake(deltaLat, deltaLon)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegionMake(localizacao, areaExibicao)
        
        mapa.setRegion(regiao, animated: true)
        
        CLGeocoder().reverseGeocodeLocation(localizacaoUsuario!) { (detalhesLocal, erro) in
            if erro == nil {
                
                if let dadosLocal = detalhesLocal?.first {
                
                    var endNome = ""
                    if dadosLocal.name != nil {
                        endNome = (dadosLocal.name)!
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
                    }
                    if endNome == endRua+", "+endNumero {
                        self.enderecoLabel.text = endRua + ", " +
                                                    endNumero + " / " +
                                                    endCidade + " / " +
                                                    endPais
                    }else{
                        self.enderecoLabel.text = endNome + " - " +
                                                    endRua + ", " +
                                                    endNumero + " / " +
                                                    endCidade + " / " +
                                                    endPais
                    }
//                    print("\n / thoroughfare: " + endRua +
//                        "\n / subThoroughfare: " + endNumero +
//                        "\n / locality: " + endCidade +
//                        "\n / subLocality: " + endBairro +
//                        "\n / postalCode: " + endCep +
//                        "\n / country: " + endPais +
//                        "\n / administrativaArea: " + endEstado +
//                        "\n / subAdministrativeArea: " + endSubEstado)
                    
                    
                
                }
                
            }else{
                print(erro)
            }
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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

