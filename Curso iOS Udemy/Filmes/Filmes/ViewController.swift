//
//  ViewController.swift
//  Filmes
//
//  Created by Daniel Dallagnese on 16/06/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var filmes: [Filme] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Definir filmes
        var filme: Filme
        filme = Filme(titulo: "007 - Spectre", descricao: "Descrição 1", imagem: #imageLiteral(resourceName: "filme1"))
        filmes.append(filme)
        filme = Filme(titulo: "Star Wars", descricao: "Descrição 2", imagem: #imageLiteral(resourceName: "filme2"))
        filmes.append(filme)
        filme = Filme(titulo: "Impacto Mortal", descricao: "Descrição 3", imagem: #imageLiteral(resourceName: "filme3"))
        filmes.append(filme)
        filme = Filme(titulo: "Deadpool", descricao: "Descrição 4", imagem: #imageLiteral(resourceName: "filme4"))
        filmes.append(filme)
        filme = Filme(titulo: "O Regresso", descricao: "Descrição 5", imagem: #imageLiteral(resourceName: "filme5"))
        filmes.append(filme)
        filme = Filme(titulo: "A Herdeira", descricao: "Descrição 6", imagem: #imageLiteral(resourceName: "filme6"))
        filmes.append(filme)
        filme = Filme(titulo: "Caçadores de Emoção", descricao: "Descrição 7", imagem: #imageLiteral(resourceName: "filme7"))
        filmes.append(filme)
        filme = Filme(titulo: "Regresso do Mal", descricao: "Descrição 8", imagem: #imageLiteral(resourceName: "filme8"))
        filmes.append(filme)
        filme = Filme(titulo: "Tarzan", descricao: "Descrição 9", imagem: #imageLiteral(resourceName: "filme9"))
        filmes.append(filme)
        filme = Filme(titulo: "Hardcore", descricao: "Descrição 10", imagem: #imageLiteral(resourceName: "filme10"))
        filmes.append(filme)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filmes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filme = filmes[indexPath.row]
        // Definir o nome da table view cell para usar aqui
        let celulaReuso = "celulaReuso"
        let celula = tableView.dequeueReusableCell(withIdentifier: celulaReuso, for: indexPath) as! FilmeCelula
        
        celula.filmeImageView.image = filme.imagem
        celula.tituloLabel.text = filme.titulo
        celula.descricaoLabel.text = filme.descricao
        
        /*celula.filmeImageView.layer.cornerRadius = 42
        celula.filmeImageView.clipsToBounds = true*/
        
        return celula
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detalheFilme" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let filmeSelecionado = self.filmes[indexPath.row]
                let viewControllerDestino = segue.destination as! DetalhesFilmeViewController
                viewControllerDestino.filme = filmeSelecionado
            }
        }
    }


}

