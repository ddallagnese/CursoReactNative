//
//  ClassificacaoViewController.swift
//  Kart
//
//  Created by Daniel Dallagnese on 18/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ClassificacaoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var consideraDescarte: UISwitch!
    
    var campeonato: String!
    var resultadosDescartar: Int = 0
    var pontuacao = [String : Int]()
    var participantes: [Participante] = []
    var bateriasRealizadas: [Bateria] = []
    var classificacao: [Classificacao] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        self.title = "Classificação"
        
        atualizaClassificacao()
        
        consideraDescarte.addTarget(self, action: (#selector(ClassificacaoViewController.atualizaClassificacao)), for: UIControlEvents.valueChanged)
    }
    
    func atualizaClassificacao() {
        DataManager.sharedInstance.carregaDescarte { (resultadosDescartar) in
            self.resultadosDescartar = resultadosDescartar
            DataManager.sharedInstance.carregaPontuacao { (pontuacao) in
                self.pontuacao = pontuacao
                DataManager.sharedInstance.carregaParticipantes { (participantes) in
                    self.participantes = participantes
                    DataManager.sharedInstance.carregaBaterias { (bateriasRealizadas, bateriasPendentes) in
                        self.bateriasRealizadas = bateriasRealizadas
                        self.calculaClassificacao()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func calculaClassificacao() {
        // Organiza os participantes e suas pontuações na variável pontuacao
        var pontuacao: [PontuacaoPilotoPorBateria] = []
        var pontosPiloto: [Int] = []
        var pontosBateria: Int
        for i in 0 ..< participantes.count {
            pontosPiloto = []
            for j in 0 ..< bateriasRealizadas.count {
                pontosBateria = 0
                for k in 0 ..< bateriasRealizadas[j].resultados.count {
                    if participantes[i].nome == bateriasRealizadas[j].resultados[k].piloto {
                        pontosBateria += bateriasRealizadas[j].resultados[k].pontos
                    }
                }
                for k in 0 ..< bateriasRealizadas[j].extras.count {
                    if participantes[i].nome == bateriasRealizadas[j].extras[k].piloto {
                        pontosBateria += bateriasRealizadas[j].extras[k].pontos
                    }
                }
                pontosPiloto.append(pontosBateria)
            }
            pontosPiloto = pontosPiloto.sorted(by: { $0 > $1 } )
            pontuacao.append(PontuacaoPilotoPorBateria(piloto: participantes[i].nome, pontuacao: pontosPiloto))
        }
        
        // Define quantos resultados serão descartados
        var descartar = 0
        if bateriasRealizadas.count > resultadosDescartar {
            consideraDescarte.isEnabled = true
            if consideraDescarte.isOn {
                descartar = resultadosDescartar
            }
        }else{
            consideraDescarte.isOn = false
            consideraDescarte.isEnabled = false
        }
        
        // Calcula a pontuação total de cada participante
        classificacao = []
        var totalPontos: Int
        for i in 0 ..< pontuacao.count {
            totalPontos = 0
            for j in 0 ..< (pontuacao[i].pontuacao.count - descartar) {
                totalPontos += pontuacao[i].pontuacao[j]
            }
            classificacao.append(Classificacao(piloto: pontuacao[i].piloto, pontos: totalPontos))
        }
        classificacao = classificacao.sorted(by: { $0.pontos > $1.pontos } )
    }
}

extension ClassificacaoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if consideraDescarte.isOn {
            if bateriasRealizadas.count - resultadosDescartar == 1 {
                return "Pontuação do melhor resultado"
            }else{
                return "Pontuação dos "+String(bateriasRealizadas.count - resultadosDescartar)+" melhores resultados"
            }
        }else{
            return "Pontuação total"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classificacao.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "classificacao", for: indexPath) as! ClassificacaoCelula
        
        celula.posicao.text = String(indexPath.row + 1)
        celula.piloto.text = self.classificacao[indexPath.row].piloto
        celula.pontos.text = String(self.classificacao[indexPath.row].pontos)
        
        return(celula)
    }
    
}
