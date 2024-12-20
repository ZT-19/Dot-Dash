//
//  ContentView.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 10/26/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var context = DOGameContext(dependencies: .init(), gameMode: .single)
    
    var body: some View {
        ZStack {
            SpriteView(scene: context.scene!, debugOptions: [.showsFPS, .showsNodeCount])
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }
        .statusBarHidden()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
