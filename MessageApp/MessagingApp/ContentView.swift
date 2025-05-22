//
//  ContentView.swift
//  MessagingApp
//
//  Created by Sam on 20/5/25.
//

import SwiftUI

struct ContentView: View {
//    let chatViewModel = ChatViewModel(user: <#String#>, service: LocalSocketService.shared)
    let logInViewModel = LoginViewModel(service: PasswordAuthenticationService())
    
    var body: some View {
        NavigationView {
            LogInView(viewModel: logInViewModel)
        }
    }
}

#Preview {
    ContentView()
}
