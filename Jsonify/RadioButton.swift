//
//  RadioButton.swift
//  Jsonify
//
//  Created by MrDev on 01/03/2022.
//

import SwiftUI

struct RadioButton: View {
    let label: String
    @Binding var checked: Bool
    let onTapOn: ()-> Void?
    let onTapOff: ()-> Void?
    
    var body: some View {
        Group{
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                if checked {
                    ZStack{
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }.onTapGesture {
                        self.checked = false
                        self.onTapOff()
                        
                    }
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .onTapGesture {
                            self.checked = true
                            self.onTapOn()}
                }
                Text(label)
            })
        }
    }
}

struct RadioButtonPreviews: PreviewProvider {
    static var previews: some View {
        RadioButton(label: "test", checked: Binding.constant(true)) {
        } onTapOff: {}
    }
}
