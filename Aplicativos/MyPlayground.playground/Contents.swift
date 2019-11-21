//: Playground - noun: a place where people can play

import UIKit


let dictionary = ["main course": 10.99, "dessert": 2.99, "salad": 5.99]
let sortedKeysAndValues = Array(dictionary).sorted(by: { $0.0 < $1.0 })
print(sortedKeysAndValues)


let d = [
    "A" : [1, 2],
    "Z" : [3, 4],
    "D" : [5, 6]
]

for (k,v) in Array(d).sorted(by: {$0.0 < $1.0}) {
    print("\(k):\(v)")
}