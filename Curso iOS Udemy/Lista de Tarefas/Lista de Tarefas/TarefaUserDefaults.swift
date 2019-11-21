//
//  TarefaUserDefaults.swift
//  Lista de Tarefas
//
//  Created by Daniel Dallagnese on 17/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class TarefaUserDefaults {
    
    let chaveListaTarefa = "listaTarefa"
    var tarefas: [String] = []
    
    func salvarTarefa(tarefa: String) {
        
        tarefas = listarTarefas()
        
        tarefas.append(tarefa)
        UserDefaults.standard.set(tarefas, forKey: chaveListaTarefa)
        
    }
    
    func listarTarefas() -> Array<String> {
        
        let dados = UserDefaults.standard.object(forKey: chaveListaTarefa)
        
        if dados != nil {
            return dados as! Array<String>
        }
        else {
            return []
        }
    }
    
    func removerTarefa(indice: Int) {
        tarefas = listarTarefas()
        tarefas.remove(at: indice)
        UserDefaults.standard.set(tarefas, forKey: chaveListaTarefa)
    }
    
}
