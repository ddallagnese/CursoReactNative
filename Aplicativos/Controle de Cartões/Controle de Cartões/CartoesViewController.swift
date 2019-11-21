//
//  CartoesViewController.swift
//  Controle de Cartões
//
//  Created by Daniel Dallagnese on 13/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit

class CartoesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var cartoes: [Cartao] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cartao = Cartao(nomeCartao: "Visa Itaú", venctoFatura: Date(), valorFatura: 0)
        cartoes.append(cartao)
        cartao = Cartao(nomeCartao: "Master Itaú", venctoFatura: Date(), valorFatura: 0)
        cartoes.append(cartao)
        cartao = Cartao(nomeCartao: "Credicard", venctoFatura: Date(), valorFatura: 0)
        cartoes.append(cartao)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaCartao", for: indexPath) as! CartoesCelula
//        celula.textLabel?.text = cartoes[indexPath.row].nomeCartao
        celula.nomeCartao.text = cartoes[indexPath.row].nomeCartao
        celula.valorFatura.text = String(cartoes[indexPath.row].valorFatura)
        celula.venctoFatura.text = String(describing: cartoes[indexPath.row].venctoFatura)
        return celula
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
