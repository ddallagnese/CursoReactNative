//
//  ViewController.swift
//  Kart
//
//  Created by Daniel Dallagnese on 14/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class BateriasViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var campeonato: String = "Ligeirinho 2017"
    var bateriasRealizadas: [Bateria] = []
    var bateriasFuturas: [Bateria] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        DataManager.sharedInstance.carregaPontuacao { (pontuacao) in
            DataManager.sharedInstance.carregaBaterias { (bateriasRealizadas, bateriasFuturas) in
                self.bateriasRealizadas = bateriasRealizadas
                self.bateriasFuturas = bateriasFuturas
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = campeonato
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BateriasViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Baterias realizadas"
        }else{
            return "Baterias futuras"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bateriasRealizadas.count
        }else{
            return bateriasFuturas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bateria: Bateria
        let nomeCelula: String
        if indexPath.section == 0 {
            bateria = bateriasRealizadas[indexPath.row]
            nomeCelula = "bateriaRealizada"
        }else{
            bateria = bateriasFuturas[indexPath.row]
            nomeCelula = "bateriaFutura"
        }
        let celula = tableView.dequeueReusableCell(withIdentifier: nomeCelula, for: indexPath) as! BateriaCelula
        
        celula.numero = bateria.numero
        celula.data.text = bateria.data
        celula.hora.text = bateria.hora
        celula.local.text = bateria.local
        celula.cidade.text = bateria.cidade
        
        return(celula)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.title = "Baterias"
        if let indexPath = tableView.indexPathForSelectedRow {
            if segue.identifier == "bateriaResultado" {
                let viewControllerDestino = segue.destination as! ResultadoBateriaViewController
                viewControllerDestino.bateria = self.bateriasRealizadas[indexPath.row]
// TODO: criar segue "bateriaConfirmacao" para navegar da célula de bateria pendente para a tela de confirmação
// criar também a tela de confirmação
//            }else if segue.identifier == "bateriaConfirmacao" {
//                let viewControllerDestino = segue.destination as! ConfirmacaoBateriaViewController
//                viewControllerDestino.bateria = self.bateriasPendentes[indexPath.row]
            }
        }
    }
 
}
