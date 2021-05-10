//
//  EditCardsView.swift
//  FlashZilla
//
//  Created by Kristoffer Eriksson on 2021-05-08.
//

import SwiftUI

struct EditCardsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add new card")) {
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("add card", action: addCard)
                }
                
                Section {
                    ForEach(0..<cards.count, id: \.self){ index in
                        VStack(alignment: .leading){
                            Text(self.cards[index].prompt)
                                .font(.headline)
                            Text(self.cards[index].answer)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationBarTitle("Edit Cards")
            .navigationBarItems(trailing: Button("Done", action: dismiss))
            .listStyle(GroupedListStyle())
            .onAppear(perform: loadData)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func dismiss(){
        presentationMode.wrappedValue.dismiss()
    }
    
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards"){
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                self.cards = decoded
            }
        }
    }
    
    func saveData(){
        if let data = try? JSONEncoder().encode(cards){
            UserDefaults.standard.set(data, forKey: "Cards")
        }
    }
    
    func addCard(){
        let trimmedPrompts = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        
        guard trimmedPrompts.isEmpty == false && trimmedAnswer.isEmpty == false else {return}
        
        let card = Card(prompt: trimmedPrompts, answer: trimmedAnswer)
        
        cards.insert(card, at: 0)
        saveData()
    }
    
    func removeCards(at offset: IndexSet){
        cards.remove(atOffsets: offset)
        saveData()
    }
}

struct EditCardsView_Previews: PreviewProvider {
    static var previews: some View {
        EditCardsView()
    }
}
