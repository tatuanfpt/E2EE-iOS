//
//  ContentView.swift
//  MessagingApp
//
//  Created by Sam on 20/5/25.
//

import SwiftUI

struct ContentView: View {
    let chatViewModel = ChatViewModel(service: LocalSocketService.shared)
    
    var body: some View {
        ChatView(viewModel: chatViewModel)
    }
}

#Preview {
    ContentView()
}
