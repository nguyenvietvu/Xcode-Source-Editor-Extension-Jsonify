//
//  ContentView.swift
//  Jsonity
//
//  Created by MrDev on 26/02/2022.
//

import SwiftUI

struct ContentView: View {
    let storage: UserDefaults = UserDefaults(suiteName: C.APP_GROUP_ID)!
    @State private var type = UserDefaults(suiteName: C.APP_GROUP_ID)!.type
    @State private var hasCodingKey = UserDefaults(suiteName: C.APP_GROUP_ID)!.hasCodingKey
    @State private var hasDefault = UserDefaults(suiteName: C.APP_GROUP_ID)!.hasDefault
    @State private var isOverride = UserDefaults(suiteName: C.APP_GROUP_ID)!.isOverride
    @State private var checked = false
    @State private var saved = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 4.0, content: {
            Text("Configuration")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .center, spacing: nil, content: {
                VStack(alignment: .center, spacing: nil, content: {
                    Text("Type")
                    RadioButton(label: "var", checked: Binding.constant(type == "var")) {
                        type = "var"
                    } onTapOff: {}
                    RadioButton(label: "let", checked: Binding.constant(type == "let")) {
                        changeToLet()
                    } onTapOff: {}
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                VStack(alignment: .leading, spacing: nil, content: {
                    Toggle("Override selection", isOn: $isOverride).onChange(of: isOverride, perform: { value in
                        isOverride = value
                    })
                    Toggle("Coding Key", isOn: $hasCodingKey).onChange(of: hasCodingKey, perform: { value in
                        hasCodingKey = value
                    })
                    Toggle("Default Value", isOn: $hasDefault).onChange(of: hasDefault, perform: { value in
                        hasDefault = value
                    }).opacity(type == "let" ? 0 : 1)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            })
            
            HStack(alignment: .center, spacing: 32.0, content: {
                Button("Reset") {
                    reset()
                }
                Button("save") {
                    self.saved = true
                    self.save()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.saved = false
                    }
                }
            }).frame(width: 200, height: 50, alignment: .center)
            Text("Saved")
                .foregroundColor(.white)
                .fontWeight(.thin)
                .font(.system(size: 10))
                .frame(width: 200, height: 30, alignment: .bottom)
                .opacity(saved ? 1 : 0)
                .animation(.easeInOut(duration: 1.0))
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.0)))
            Text("©MrDev 2022")
                .foregroundColor(.gray)
                .fontWeight(.thin)
                .padding()
                .font(.system(size: 10))
                .frame(width: 200, height: 40, alignment: .bottom)
        })
        .frame(width: 360.0, height: 250.0)
    }
    
    func changeToLet(){
        type = "let"
        hasDefault = false
    }
    
    func save(){
        storage.type = type
        storage.hasCodingKey = hasCodingKey
        storage.hasDefault = hasDefault
        storage.isOverride = isOverride
    }
    
    func reset(){
        type = "var"
        hasCodingKey = false
        hasDefault = false
        isOverride = true
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
