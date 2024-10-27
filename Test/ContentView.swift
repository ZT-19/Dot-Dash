//
//  ContentView.swift
//  Test
//
//  Created by Hyung Lee on 10/18/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let context = TTGameContext(dependencies: .init(),
                                gameMode: .single)
    let screenSize: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        SpriteView(scene: TTGameScene(context: context,
                                      size: screenSize))
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}
