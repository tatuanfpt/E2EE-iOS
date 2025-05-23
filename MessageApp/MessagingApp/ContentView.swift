//
//  ContentView.swift
//  MessagingApp
//
//  Created by Sam on 20/5/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var flow = Flow()
    private let factory = Factory()
    
    var body: some View {
        NavigationStack(path: $flow.path) {
            LogInView(viewModel: LoginViewModel(service: PasswordAuthenticationService(), didLogin: { sender in
                flow.start(type: .pushTo(ConversationDestination.conversation(sender: sender)))
            }))
            .navigationDestination(for: ConversationDestination.self) { destination in
                switch destination {
                case.conversation(let sender):
                    factory.createConversation(sender: sender, didTapItem: { sender, receiver in
                        flow.start(type: .pushTo(ConversationDestination.chat(sender: sender, receiver: receiver)))
                    })
                case .chat(let sender, let receiver):
                    factory.createChat(sender: sender, receiver: receiver)
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
