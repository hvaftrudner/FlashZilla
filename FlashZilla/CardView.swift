//
//  CardView.swift
//  FlashZilla
//
//  Created by Kristoffer Eriksson on 2021-05-07.
//

import SwiftUI

struct CardView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    @Binding var answer: Bool
    @Binding var removeWrongAnswer: Bool
    let card: Card
    var removal : (() -> Void)? = nil
    
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white.opacity(1 - Double(abs(offset.width / 50))))
                .modifier(BackGroundModifier(colorMode: differentiateWithoutColor, offset: offset))
                .shadow(radius: 10)
            
            VStack{
                if accessibilityEnabled{
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(Color.black)
                    
                    if isShowingAnswer{
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare()
                    
                }
                .onEnded{ _ in
                    if abs(self.offset.width) > 100 {
                        //remove card
                        
                        if self.offset.width > 0 {
                            self.feedback.notificationOccurred(.success)
                            self.answer = true
                            
                        } else {
                            self.feedback.notificationOccurred(.error)
                            self.answer = false
                        }
                        
                        self.removal?()
                        
                    } else {
                        self.offset = .zero
                    }
                }
        )
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .animation(.spring())
    }
}

struct BackGroundModifier: ViewModifier {
    
    let colorMode: Bool
    let offset: CGSize
    
    var backGround: Color {
        if offset.width > 0 {
            return Color.green
        } else if offset.width == 0 {
            return Color.white
        } else {
            return Color.red
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                colorMode
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(backGround))
    }
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView(card: Card.example)
//    }
//}
