//
//  SourceEditorCommand.swift
//  Parser
//
//  Created by MrDev on 30/02/2022.
//

import Foundation
import XcodeKit

typealias KVArray = [(key: String, value: Any?)]
typealias KVDict = [String: Any?]
typealias KV = (key: String, value: Any?)

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    let storage = UserDefaults(suiteName: C.APP_GROUP_ID)!
    var kvStrs = [String]()
    var type = "var"
    var src = ""
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines = invocation.buffer.lines
        type = UserDefaults(suiteName: C.APP_GROUP_ID)!.type
        src = source(from: invocation.buffer)
        src = fixJson(from: src)
        
        if let error = validate(json: src){
            if let range = invocation.buffer.selections[0] as? XCSourceTextRange {
                lines.replaceObject(at: range.end.line-1, with: "//\(error.rawValue)")
            }
        } else {
            if let dict = src.toKVDict(){
                let kvStr = parseJson(name: "SampleJson", dict: reorder(json: src, dict: dict))
                kvStrs.append(kvStr)
                if(storage.isOverride){
                    if let range = invocation.buffer.selections[0] as? XCSourceTextRange {
                        for _ in range.start.line...range.end.line {
                            if(lines.count >= range.start.line+1){
                                lines.removeObject(at: range.start.line)
                            }
                        }
                    }
                }
                kvStrs.forEach { string in
                    lines.add(string)
                }
            } else {
                if let range = invocation.buffer.selections[0] as? XCSourceTextRange {
                    lines.replaceObject(at: range.end.line-1, with: FormatError.parsingError.rawValue)
                }
            }
            
        }
        completionHandler(nil)
    }
    
    func parseJson(name: String = "DataModel", dict: KVArray) -> String{
        let tabs = "    "
        let tabs2 = "        "
        var retStr = "struct \(name): Codable {\n"
        
        for (key, value) in dict {
            if(value != nil){
                if isBool(value!) {
                    if(storage.hasDefault){
                        retStr += "\(tabs)\(type) \(key.toCamel()): Bool = false\n"
                    } else {
                        retStr += "\(tabs)\(type) \(key.toCamel()): Bool\n"
                    }
                } else {
                    switch value {
                    case is Int:
                        retStr += "\(tabs)\(type) \(key.toCamel()): Int\(storage.hasDefault ? " = 0" : "")\n"
                    case is Int64:
                        retStr += "\(tabs)\(type) \(key.toCamel()): Int64\(storage.hasDefault ? " = 0" : "")\n"
                    case is Float:
                        retStr += "\(tabs)\(type) \(key.toCamel()): Float\(storage.hasDefault ? " = 0.0f" : "")\n"
                    case is Double:
                        retStr += "\(tabs)\(type) \(key.toCamel()): Double \(storage.hasDefault ? " = 0.0" : "")\n"
                    case is String:
                        retStr += "\(tabs)\(type) \(key.toCamel()): String\(storage.hasDefault ? " = \"\"" : "")\n"
                    case is Array<Any>:
                        let arr = value as! [Any?]
                        if(arr.isEmpty){
                            retStr += "\(tabs)\(type) \(key.toCamel()): [String]\(storage.hasDefault ? " = []" : "")\n"
                        } else {
                            if let val = arr[0]{
                                if isBool(val) {
                                    retStr += "\(tabs)\(type) \(key): [Bool]\(storage.hasDefault ? " = false" : "")\n"
                                } else {
                                    switch val {
                                    case is Int:
                                        retStr += "\(tabs)\(type) \(key.toCamel()): [Int]\(storage.hasDefault ? " = []" : "")\n"
                                    case is Int64:
                                        retStr += "\(tabs)\(type) \(key.toCamel()): [Int64]\(storage.hasDefault ? " = []" : "")\n"
                                    case is Double:
                                        retStr += "\(tabs)\(type) \(key.toCamel()): [Double]\(storage.hasDefault ? " = []" : "")\n"
                                    case is String:
                                        retStr += "\(tabs)\(type) \(key.toCamel()): [String]\(storage.hasDefault ? " = []" : "")\n"
                                    default:
                                        retStr += "\(tabs)\(type) \(key.toCamel()): [\(key.capitalized)]\(storage.hasDefault ? " = []" : "")\n"
                                        let kvDict = val as! KVDict
                                        let kvStr = parseJson(name: key.capitalized, dict: reorder(json: src, dict: kvDict))
                                        kvStrs.append(kvStr)
                                    }
                                }
                            } else {
                                retStr += "\(tabs)\(type) \(key): [String?]\(storage.hasDefault ? " = []" : "")\n"
                            }
                        }
                    default:
                        retStr += "\(tabs)\(type) \(key.toCamel()): \(key.capitalized)\n"
                        let kvDict = value as! KVDict
                        let kvStr = parseJson(name: key.capitalized, dict: reorder(json: src, dict: kvDict))
                        kvStrs.append(kvStr)
                    }
                }
            } else {
                retStr += "\(tabs)\(type) \(key): String?\(storage.hasDefault ? " = nil" : "")\n"
            }
        }
        
        if(storage.hasCodingKey){
            retStr += "\n"
            retStr += "\(tabs)enum CodingKeys: String, CodingKey {\n"
            for (key, _) in dict {
                retStr += "\(tabs2)case \(key.toCamel()) = \"\(key)\"\n"
            }
            retStr += "\(tabs)}\n"
        }
        
        retStr += "}\n"
        return retStr
    }
    
    func isBool(_ value: Any)-> Bool{
        let stringMirror = Mirror(reflecting: value)
        let type = "\(stringMirror.subjectType)"
        return (type == "__NSCFBoolean")
    }
    
    func reorder(json: String, dict: KVDict)->KVArray{
        var items = KVArray()
        dict.forEach { item in
            items.append(item)
        }
        var positions = [(pos: Int, val: KV)]()
        items.forEach { item in
            if let r = json.range(of: item.key){
                let p = json.distance(from: json.startIndex, to: r.lowerBound)
                positions.append((pos: p, val: item))
            }
        }
        positions.sort { item1, item2 in
            item1.pos < item2.pos
        }
        items.removeAll()
        positions.forEach { (pos: Int, val: (key: String, value: Any?)) in
            items.append(val)
        }
        return items
    }
    
    func source(from buffer: XCSourceTextBuffer) -> String {
        var text = ""
        for case let range as XCSourceTextRange in buffer.selections {
            for lineNumber in range.start.line...range.end.line {
                if lineNumber >= buffer.lines.count {
                    continue
                }
                guard let line = buffer.lines[lineNumber] as? String else {
                    continue
                }
                text.append(String(line))
            }
        }
        return text.replacingOccurrences(of: "\\", with: "")
    }
    
    func fixJson(from src: String)->String{
        var text = src
        if let error = validate(json: text){
            switch error {
            case .missingBrackets:
                text = "{" + text + "}"
            case .missingBracketClose:
                text = text + "}"
            case .missingBracketOpen:
                text = "{" + text
            default:
                break
            }
        }
        
        let start = text.firstIndex(of: "{")
        let end = text.lastIndex(of: "}")
        if let start = start, let end = end {
            let finalJson = text[start...end]
            text = String(finalJson)
        }
        return text
    }
    
    func validate(json: String)->FormatError?{
        let countBracket1 = json.components(separatedBy:"{").count
        let countBracket2 = json.components(separatedBy:"}").count
        let countSBracket1 = json.components(separatedBy:"[").count
        let countSBracket2 = json.components(separatedBy:"]").count
        
        if(countBracket1 == 1 && countBracket2 == 1){
            return .missingBrackets
        }
        
        if(countBracket1 == 1){
            return .missingBracketOpen
        }
        
        if(countBracket2 == 1){
            return .missingBracketClose
        }
        
        if(countBracket1 > countBracket2){
            return .missingBracketClose
        }
        
        if(countBracket1 < countBracket2){
            return .missingBracketClose
        }
        
        if(countSBracket1 > countSBracket2){
            return .missingSBracketClose
        }
        
        if(countSBracket1 < countSBracket2){
            return .missingSBracketOpen
        }
        
        return nil
    }
}
