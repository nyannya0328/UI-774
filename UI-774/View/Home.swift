//
//  Home.swift
//  UI-774
//
//  Created by nyannyan0328 on 2022/10/20.
//SCROLLER

import SwiftUI

struct Home: View {
    @State var characters : [Character] = []
    @State var startOffset  :CGFloat = 0
    
    @State var scrollHeight  :CGFloat = 0
    @State var indicatorOffset  :CGFloat = 0
    
    @State var currentCharacterValue : Character = .init(value:"")
    @State var timout : CGFloat = 0
     @State var hideIndicatorLable  : Bool = false
    var body: some View {
        NavigationStack{
            
            GeometryReader{
                
                let size = $0.size
                
                ScrollViewReader { proxy in
                
                    ScrollView(.vertical,showsIndicators: false){
                        
                        
                        VStack(spacing: 0) {
                            
                            ForEach(characters) { character in
                                
                                contarctForCharacter(character: character)
                                    .id(character.index)
                            }
                        }
                        .padding()
                        .padding(.top,15)
                        .offset { rect in
                            
                            if hideIndicatorLable && rect.minY < 0{
                                hideIndicatorLable = false
                                timout = 0
                            }
                            
                            let rectH = rect.height
                            let viewH = size.height + (startOffset / 2)
                            
                            let scrollH = (viewH / rectH) * viewH
                            
                            self.scrollHeight = scrollH
                            
                            let progress = rect.minY / (rectH - size.height)
                            
                            self.indicatorOffset = -progress * (size.height - scrollH)
                            
                            
                        }
                        
                        
                        
                    }
                    
                }
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .overlay(alignment: .topTrailing) {
                      
                      
                      Rectangle()
                          .fill(.clear)
                       .frame(width: 2,height: scrollHeight)
                       .offset(y:indicatorOffset)
                       .overlay(alignment: .trailing) {
                           
                           
                            Image(systemName: "bubble.middle.bottom.fill")
                               .resizable()
                               .renderingMode(.template)
                               .aspectRatio(contentMode: .fit)
                              .frame(width: 45,height: 45)
                              .rotationEffect(.init(degrees:90))
                              .overlay(content: {
                                  
                                  Text(currentCharacterValue.value)
                                      .font(.title.bold())
                              })
                              
                              .foregroundStyle(.ultraThinMaterial)
                              .environment(\.colorScheme, .dark)
                              .offset(x:hideIndicatorLable && currentCharacterValue.value == "" ? 65 : 0)
                              .animation(.interactiveSpring(response: 1.1,dampingFraction: 0.85,blendDuration: 0.85), value: hideIndicatorLable || currentCharacterValue.value == "")
                              
                           
                       }
                       .offset(y:indicatorOffset)
                      
                  }
                  .coordinateSpace(name: "SCROLLER")
                
            }
            .navigationTitle("Contact")
            .offset { rect in
                if startOffset != rect.minY{
                    
                    startOffset = rect.minY
                }
                
            }
            
            
        }
        .onAppear{characters = fetchCharacters()}
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            
            if timout < 0.3{
                
                timout += 0.1
            }
            else{
                if !hideIndicatorLable{
                    
                    hideIndicatorLable = true
                }
            }
        }
    }
    @ViewBuilder
    func contarctForCharacter(character : Character)->some View{
        
        VStack(alignment: .leading) {
            
            Text(character.value)
                .font(.largeTitle.bold())
            
            ForEach(1...4 ,id:\.self){index in
                
                HStack{
                    
                    Circle()
                        .fill(character.color.gradient)
                        .frame(width: 60,height: 60)
                    
                    VStack(alignment: .leading,spacing: 10) {
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color)
                            .frame(height:20)
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(character.color)
                            .frame(height:20)
                            .padding(.trailing,100)
                        
                        
                    }
                }
            }
            
        }
        .offset { rect in
            
            if characters.indices.contains(character.index){
                
                characters[character.index].rect = rect
            }
            
            if let last = characters.last(where: { char in
                char.rect.minY < 0
                
            }),last.id != currentCharacterValue.id{
                
                currentCharacterValue = last
            }
        }
        
        
    }
    
    func fetchCharacters()->[Character]{
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var characters : [Character] = []
        
        characters = alphabet.compactMap({ character -> Character? in
            
            return Character(value: String(character))
            
        })
        
        let colos : [Color] = [.red,.yellow,.gray,.green,.orange,.purple,.indigo,.blue,.pink]
        
        for index in characters.indices{
            characters[index].index = index
            characters[index].color = colos.randomElement()!
            
        }
    
        return characters
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View{
    @ViewBuilder
    func offset(competion : @escaping(CGRect) -> ())->some View{
        
        self
            .overlay {
                
                GeometryReader{
                    
                    let rect = $0.frame(in: .named("SCROLLER"))
                    
                    Color.clear
                        .preference(key:OffsetKey.self, value: rect)
                        .onPreferenceChange(OffsetKey.self) { value in
                            
                            competion(value)
                        }
                
                    
                }
                
            }
        
        
    }
}

struct OffsetKey : PreferenceKey{
    
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
