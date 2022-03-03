//
//  UserDefaults.swift
//  Jsonify
//
//  Created by MrDev on 01/03/2022.
//

import Foundation
extension UserDefaults {
    var type: String {
        get {
            return string(forKey: "type") ?? "var"
        }
        set(value){
            set(value, forKey: "type")
            synchronize()
        }
    }
    
    var hasCodingKey: Bool {
        get {
            return bool(forKey: "has_coding_key")
        }
        set(value){
            set(value, forKey: "has_coding_key")
            synchronize()
        }
    }
    
    var hasDefault: Bool {
        get {
            return bool(forKey: "has_default")
        }
        set(value){
            set(value, forKey: "has_default")
            synchronize()
        }
    }
    
    var isOverride: Bool {
        get {
            return bool(forKey: "is_override")
        }
        set(value){
            set(value, forKey: "is_override")
            synchronize()
        }
    }
}
