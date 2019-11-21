//
//  ViewController.swift
//  Core Data
//
//  Created by Daniel Dallagnese on 03/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configurações do Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Salvar os dados com Core Data
        let produto = NSEntityDescription.insertNewObject(forEntityName: "Produtos", into: context)
        
        // Configurar objeto
/*        produto.setValue("Notebook HP", forKey: "nome")
        produto.setValue("descricao 5", forKey: "descricao")
        produto.setValue("preto", forKey: "cor")
        produto.setValue(1399, forKey: "preco")
        
        do {
            try context.save()
            print("Dados salvos")
        }catch{
            print("Erro ao sakvar os dados")
        }*/
        
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Produtos")
        
        // Ordenação
        let ordenacaoAZ = NSSortDescriptor(key: "nome", ascending: true)
        //let ordenacaoZA = NSSortDescriptor(key: "preco", ascending: false)
        
        // Filtros
        //let predicate = NSPredicate(format: "preco < 200")
        //let filtroNome = NSPredicate(format: "nome beginswith [c] %@", "ipho")
        //let filtroPreco = NSPredicate(format: "preco < 200")
        
        //let combinacaoFiltros = NSCompoundPredicate(andPredicateWithSubpredicates: [filtroNome, filtroPreco])
        //let combinacaoFiltros = NSCompoundPredicate(orPredicateWithSubpredicates: [filtroNome, filtroPreco])
        
        // Aplicar filtros à requisição
        requisicao.sortDescriptors = [ordenacaoAZ]
        //requisicao.predicate = filtroNome
        
        do {
            let produtos = try context.fetch(requisicao)
            if produtos.count > 0 {
                for produto in produtos as! [NSManagedObject] {
                    let nomeProduto = (produto as AnyObject).value(forKey: "nome")
                    let precoProduto = (produto as AnyObject).value(forKey: "preco")
                    
                    print(String(describing: nomeProduto) + String(describing: precoProduto))
                    
                    // deletar
//                    context.delete(produto)
                    
                    // Atualizar
                    //(produto as AnyObject).setValue(199, forKey: "preco")
                    //(produto as AnyObject).setValue("iPhone 5S", forKey: "nome")
                    
//                    do {
//                        try context.save()
//                        print("Sucesso")
//                    }catch{
//                        print("Erro")
//                    }
                }
            }else{
                print("Nenhum produto encontrado")
            }
        }catch{
            print("Erro ao recuperar os dados")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

