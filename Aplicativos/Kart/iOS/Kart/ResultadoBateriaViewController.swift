//
//  ResultadoBateriaViewController.swift
//  Kart
//
//  Created by Daniel Dallagnese on 14/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ResultadoBateriaViewController: UITableViewController {
    
    var bateria: Bateria!
    var resultadosBateria: [ResultadoBateria] = []
    var extrasBateria: [ResultadoBateria] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = bateria.local+" - "+bateria.data
        self.title = bateria.numero

        DataManager.sharedInstance.carregaPontuacao { (pontuacao) in
            DataManager.sharedInstance.carregaBaterias { (bateriasRealizadas, bateriasPendentes) in
                for i in 0 ..< bateriasRealizadas.count {
                    if bateriasRealizadas[i].numero == self.bateria.numero {
                        self.resultadosBateria = bateriasRealizadas[i].resultados
                        self.extrasBateria = bateriasRealizadas[i].extras
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Classificação"
        }else{
            return "Pontos Extras"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return resultadosBateria.count
        }else{
            return extrasBateria.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultadoBateria: ResultadoBateria
        let nomeCelula: String
        if indexPath.section == 0 {
            resultadoBateria = resultadosBateria[indexPath.row]
            nomeCelula = "resultadoBateria"
        }else{
            resultadoBateria = extrasBateria[indexPath.row]
            nomeCelula = "extraBateria"
        }

        let celula = tableView.dequeueReusableCell(withIdentifier: nomeCelula, for: indexPath) as! ResultadoBateriaCelula
        
        celula.posicao.text = resultadoBateria.posicao
        celula.piloto.text = resultadoBateria.piloto
        celula.pontos.text = String(resultadoBateria.pontos)
        return(celula)
    }
}
