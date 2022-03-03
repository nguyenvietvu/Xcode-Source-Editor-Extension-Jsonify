//
//  File.swift
//  Parser
//
//  Created by MrDev on 27/02/2022.
//

import Foundation

extension String {
    func toKVDict() -> KVDict? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let dict = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? KVDict
        return dict
    }
    
    func isSnakeCase() -> Bool{
        if(self.contains("_")){
            return true
        }
        return false
    }
    
    func lowcaseFirstChar() -> String{
        return (self.first?.lowercased())! + self.suffix(self.count-1)
    }
    
    func toCamel() -> String{
        let str = self.lowcaseFirstChar()
        var ret = ""
        var i = 0
        for _ in 0..<str.count{
            if(i < str.count){
                let index = str.index(str.startIndex, offsetBy: i)
                let index1 = str.index(str.startIndex, offsetBy: i+1)
                if(str[index] == "_"){
                    ret += str[index1].uppercased()
                    i += 2
                } else {
                    ret += String(str[index])
                    i += 1
                }
            }
        }
        return ret
    }
    
}
