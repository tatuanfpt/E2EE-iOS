//
//  ContentView.swift
//  MessagingApp
//
//  Created by Sam on 20/5/25.
//

import SwiftUI

struct ContentView: View {
    let chatViewModel = ChatViewModel()
    
    var body: some View {
        ChatView(viewModel: chatViewModel)
    }
}

#Preview {
    ContentView()
}
