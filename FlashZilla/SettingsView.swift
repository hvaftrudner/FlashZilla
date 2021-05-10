//
//  SettingsView.swift
//  FlashZilla
//
//  Created by Kristoffer Eriksson on 2021-05-09.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var removeWrongCard: Bool
    
    var body: some View {
        
        VStack {
            Toggle(isOn: $removeWrongCard){
                Text("Remove wrong cards ?")
            }
            
            HStack{
                Button("Return", action: {
                    self.presentationMode.wrappedValue.dismiss()
                })
                
                Spacer()
                
                if self.removeWrongCard {
                    Text("Delete Wrong Cards")
                    
                } else {
                    Text("Remove Wrong Cards")
                }
            }    
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(removeWrongCard: true)
//    }
//}
