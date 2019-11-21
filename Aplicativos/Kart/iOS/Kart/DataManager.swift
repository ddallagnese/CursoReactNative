//
//  Firebase.swift
//  Kart
//
//  Created by Daniel Dallagnese on 18/10/2017.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DataManager {
    
    static let sharedInstance = DataManager()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    private var campeonato = "Ligeirinho 2017"
    private var resultadosDescartar: Int!
    private var pontuacao = [String : Int]()
    private var bateriasRealizadas: [Bateria] = []
    private var bateriasFuturas: [Bateria] = []
    private var participantes: [Participante] = []
    
    func carregaDescarte(_ complete:@escaping (Int)->()) {
        if self.resultadosDescartar != nil {
            complete(self.resultadosDescartar)
            return
        }
        let campeonatoReferencia = Database.database().reference().child("Campeonatos").child(campeonato)
        campeonatoReferencia.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dados = snapshot.value as? NSDictionary {
                self.resultadosDescartar = dados["Descarte"] as! Int
                print(self.resultadosDescartar)
                complete(self.resultadosDescartar)
            }
        }) { (error) in
            print("Erro ao ler os dados \(error.localizedDescription)")
            // do something to handle error
        }
    }
    
    func carregaPontuacao(_ complete:@escaping ([String : Int])->()) {        
        if self.pontuacao.count > 0 {
            complete(self.pontuacao)
            return
        }
        let pontosReferencia = Database.database().reference().child("Campeonatos").child(campeonato).child("Pontos")
        pontosReferencia.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dados = snapshot.value as? NSDictionary {
                self.pontuacao = dados as! [String : Int]
                complete(self.pontuacao)
            }
        }) { (error) in
            print("Erro ao ler os dados \(error.localizedDescription)")
            // do something to handle error
        }
    }
    
    func carregaParticipantes(_ complete:@escaping ([Participante])->()) {
        if self.participantes.count > 0 {
            complete(self.participantes)
            return
        }
        let participantesReferencia = Database.database().reference().child("Campeonatos").child(campeonato).child("Participantes")
        participantesReferencia.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dados = snapshot.value as? NSDictionary {
                for (chave, _) in dados {
                    if let dadosParticipante = dados[chave] as? NSDictionary {
                        self.participantes.append(Participante(nome: dadosParticipante["Nome"] as! String))
                    }
                }
            }
            self.participantes = self.participantes.sorted(by: { $0.nome < $1.nome })
            complete(self.participantes)
        }) { (error) in
            print("Erro ao ler os dados \(error.localizedDescription)")
            // do something to handle error
        }
    }

    func carregaBaterias(_ complete:@escaping (_ realizadas:[Bateria], _ pendentes:[Bateria])->()) {
        if self.bateriasFuturas.count > 0 || self.bateriasRealizadas.count > 0 {
            complete(self.bateriasRealizadas, self.bateriasFuturas)
            return
        }
        let bateriasReferencia = Database.database().reference().child("Campeonatos").child(campeonato).child("Baterias")
        bateriasReferencia.observeSingleEvent(of: .value, with: { (snapshot) in
            var bateria: Bateria
            let dadosSnap = snapshot.value as! NSDictionary
            for (chave, _) in dadosSnap {
                if let dados = dadosSnap[chave] as? NSDictionary {
                    bateria = Bateria(numero: chave as! String, data: dados["Data"] as! String, hora: dados["Hora"] as! String, local: dados["Local"] as! String, cidade: dados["Cidade"] as! String, resultados: [], extras: [])
                    if dados["Resultado"] == nil {
                        self.bateriasFuturas.append(bateria)
                    }else{
                        var resultadoBateria: ResultadoBateria
                        let dadosResultado = dados["Resultado"] as! NSDictionary
                        for (chave, valor) in dadosResultado {
                            resultadoBateria = ResultadoBateria(posicao: String(describing: chave), piloto: String(describing: valor), pontos: self.pontuacao[String(describing: chave)]!)
                            if Int(resultadoBateria.posicao) != nil {
                                bateria.resultados.append(resultadoBateria)
                            }else{
                                bateria.extras.append(resultadoBateria)
                            }
                        }
                        bateria.resultados = bateria.resultados.sorted(by: { $0.posicao < $1.posicao })
                        bateria.extras = bateria.extras.sorted(by: { $0.posicao < $1.posicao })
                        self.bateriasRealizadas.append(bateria)
                    }
                }
            }
            self.bateriasRealizadas = self.bateriasRealizadas.sorted(by: { $0.numero < $1.numero })
            self.bateriasFuturas = self.bateriasFuturas.sorted(by: { $0.numero < $1.numero })
            complete(self.bateriasRealizadas, self.bateriasFuturas)
        }) { (error) in
            print("Erro ao ler os dados \(error.localizedDescription)")
            // do something to handle error
        }
    }
}
