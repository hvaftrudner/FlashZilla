//
//  ContentView.swift
//  FlashZilla
//
//  Created by Kristoffer Eriksson on 2021-05-06.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    //@State private var cards = [Card](repeating: Card.example, count: 10)
    @State private var cards = [Card]()
    
    @State private var isActive = true
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isShowingEditScreen = false
    
    //Challenge 1
    @State private var isShowingEndAlert = false
    @State private var engine: CHHapticEngine?
    
    //Challenge 2
    @State private var isShowingSettings = false
    @State private var removeWrongCards = false
    @State private var wrongCard = false
    
    var body: some View {
        ZStack{
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                
                Text("Time remaining: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .opacity(0.75)
                    )
                
                ZStack{
                    ForEach(0..<cards.count, id: \.self){ index in
                        CardView(answer: $wrongCard, removeWrongAnswer: $removeWrongCards, card: self.cards[index]) {
                            withAnimation {
                                self.removeCards(at: index)
                            }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack{
                HStack{
                    Spacer()
                    
                    Button(action: {
                        self.isShowingEditScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                HStack{
                    Spacer()
                    
                    Button(action: {
                        self.isShowingSettings = true
                    }) {
                        //change icon
                        Image(systemName: "ellipsis.circle.fill")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
                
            }
            .foregroundColor(Color.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled{
                
                VStack{
                    Spacer()
                    
                    HStack{
                        Button(action: {
                            withAnimation {
                                self.removeCards(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect"))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.removeCards(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as bein correct"))
                        
                        
                    }
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer){ time in
            
            guard self.isActive else {return}
            
            if self.timeRemaining == 5 {
                //prepair haptics
                self.prepareHaptics()
            }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            
            //challenge 1
            if self.timeRemaining == 0 {
                //play haptics
                self.customHaptic()
                self.isShowingEndAlert = true
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)){ _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .sheet(isPresented: $isShowingEditScreen, onDismiss: resetCards){
            EditCardsView()
        }
        .sheet(isPresented: $isShowingSettings){
            SettingsView(removeWrongCard: $removeWrongCards)
        }
        .onAppear(perform: resetCards)
        .alert(isPresented: $isShowingEndAlert){
            Alert(title: Text("Time!"), message: Text("Your time has run out."), primaryButton: .default(Text("Restart"), action: self.resetCards), secondaryButton: .cancel())
        }
    }
    
    func removeCards(at index: Int){
        
        guard index >= 0 else {return}
        let currentCard = cards[index]
        //put at bottom of array if wrong answer
        
        cards.remove(at: index)
        
        if wrongCard == false && removeWrongCards == true {
            
            //error occured without async
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cards.insert(currentCard, at: 0)
            }
        }
        
        if cards.isEmpty{
            isActive = false
        }
    }
    
    func resetCards(){
        //cards = [Card](repeating: Card.example, count: 10)
        timeRemaining = 100
        isActive = true
        
        loadData()
    }
    
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                self.cards = decoded
            }
        }
    }
    
    //Challenge 1
    func prepareHaptics(){
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {return}
        
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting the haptics engine \(error.localizedDescription)")
        }
    }
    
    func customHaptic(){
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {return}
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 2)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1)
        
        //Buzz 2 times
        //Add different events to customize haptic
        events.append(event)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("failed to play patter \(error.localizedDescription)")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}
