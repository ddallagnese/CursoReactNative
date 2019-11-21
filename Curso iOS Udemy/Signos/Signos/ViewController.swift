//
//  ViewController.swift
//  Signos
//
//  Created by Daniel Dallagnese on 16/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var signos: [String] = []
    var significadoSignos: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lista de signos
        signos.append("Áries")
        signos.append("Touro")
        signos.append("Gêmeos")
        signos.append("Câncer")
        signos.append("Leão")
        signos.append("Virgem")
        signos.append("Libra")
        signos.append("Escorpião")
        signos.append("Sagitário")
        signos.append("Capricórnio")
        signos.append("Aquário")
        signos.append("Peixes")
        
        // Lista de significados
        significadoSignos.append("Significado Áries")
        significadoSignos.append("Significado Touro")
        significadoSignos.append("Significado Gêmeos")
        significadoSignos.append("Significado Câncer")
        significadoSignos.append("Significado Leão")
        significadoSignos.append("Significado Virgem")
        significadoSignos.append("Significado Libra")
        significadoSignos.append("Significado Escorpião")
        significadoSignos.append("Significado Sagitário")
        significadoSignos.append("Significado Capricórnio")
        significadoSignos.append("Significado Aquário")
        significadoSignos.append("Significado Peixes")
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Definir o nome da célula na table view
        let celulaReuso = "celulaReuso"
        let celula = tableView.dequeueReusableCell(withIdentifier: celulaReuso, for: indexPath)
        celula.textLabel?.text = signos[indexPath.row]
        
        return celula
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertaController = UIAlertController(title: "Significado do signo", message: significadoSignos[indexPath.row], preferredStyle: .alert)
        let acaoConfirmar = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertaController.addAction(acaoConfirmar)
        
        present(alertaController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

