//: Playground - noun: a place where people can play

import UIKit
import Foundation

let numero = NSNumber(value: 1000.2)

let nf = NumberFormatter()
nf.numberStyle = .decimal
nf.locale = Locale(identifier: "pt_BR")

if let resultado = nf.string(from: numero) {
    print(resultado)
}