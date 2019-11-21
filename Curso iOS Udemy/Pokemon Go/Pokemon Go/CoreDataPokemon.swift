//
//  CoreDataPokemon.swift
//  Pokemon Go
//
//  Created by Daniel Dallagnese on 05/07/17.
//  Copyright © 2017 Daniel Dallagnese. All rights reserved.
//

import UIKit
import CoreData

class CoreDataPokemon {
    
    // Recuperar o contexto
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        return context!
    }
    
    // Recuperar Pokemons Capturados
    func recuperarPokemonsCapturados(capturado: Bool) -> [Pokemon] {
        
        let requisicao = Pokemon.fetchRequest() as NSFetchRequest<Pokemon>
        requisicao.predicate = NSPredicate(format: "capturado = %@", capturado as CVarArg)
        
        do {
            let pokemons = try self.getContext().fetch(requisicao) as [Pokemon]
            return pokemons
        }catch{}
        
        return []
    }
    
    // Recuperar todos os Pokemons
    func recuperarTodosPokemons() -> [Pokemon] {
        do {
            let pokemons = try self.getContext().fetch(Pokemon.fetchRequest()) as! [Pokemon]
            if pokemons.count == 0 {
                adicionarTodosPokemons()
                return recuperarTodosPokemons()
            }
            return pokemons
        }catch{}
        
        return []
    }
    
    // Criar os Pokemons
    func criarPokemon(nome: String, nomeImagem: String, capturado: Bool) {
        let pokemon = Pokemon(context: self.getContext())
        pokemon.nome = nome
        pokemon.nomeImagem = nomeImagem
        pokemon.capturado = capturado
    }
    
    // Salvar o Pokemon
    func salvarPokemon (pokemon: Pokemon) {
        pokemon.capturado = true
        do {
            try self.getContext().save()
        }catch{}
    }
    
    // Adicionar os Pokemons
    func adicionarTodosPokemons() {
        self.criarPokemon(nome: "Abra", nomeImagem: "abra", capturado: false)
        self.criarPokemon(nome: "Bellsprout", nomeImagem: "bellsprout", capturado: false)
        self.criarPokemon(nome: "Bullbasaur", nomeImagem: "bullbasaur", capturado: false)
        self.criarPokemon(nome: "Caterpie", nomeImagem: "caterpie", capturado: false)
        self.criarPokemon(nome: "Charmander", nomeImagem: "charmander", capturado: false)
        self.criarPokemon(nome: "Dratini", nomeImagem: "dratini", capturado: false)
        self.criarPokemon(nome: "Eevee", nomeImagem: "eevee", capturado: true)
        self.criarPokemon(nome: "Jigglypuff", nomeImagem: "jigglypuff", capturado: false)
        self.criarPokemon(nome: "Mankey", nomeImagem: "mankey", capturado: false)
        self.criarPokemon(nome: "Meowth", nomeImagem: "meowth", capturado: false)
        self.criarPokemon(nome: "Mew", nomeImagem: "mew", capturado: false)
        self.criarPokemon(nome: "Pidgey", nomeImagem: "pidgey", capturado: false)
        self.criarPokemon(nome: "Pikachu", nomeImagem: "pikachu-2", capturado: false)
        self.criarPokemon(nome: "Psyduck", nomeImagem: "psyduck", capturado: false)
        self.criarPokemon(nome: "Rattata", nomeImagem: "rattata", capturado: false)
        self.criarPokemon(nome: "Snorlax", nomeImagem: "snorlax", capturado: false)
        self.criarPokemon(nome: "Squirtle", nomeImagem: "squirtle", capturado: false)
        self.criarPokemon(nome: "Venonat", nomeImagem: "venonat", capturado: false)
        self.criarPokemon(nome: "Weedle", nomeImagem: "weedle", capturado: false)
        self.criarPokemon(nome: "Zubat", nomeImagem: "zubat", capturado: false)
        
        do {
            try self.getContext().save()
        }catch{}
    }
}
