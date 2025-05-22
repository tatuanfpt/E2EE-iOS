//
//  SwiftUIView.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 22/5/25.
//

import SwiftUI

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @Bindable var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            TextField("Password", text: $password)
            
            Button("Login") {
                viewModel.logIn(email: email, password: password)
            }
            
            if !viewModel.isLoggedIn {
                Text("Login failed")
                    .foregroundStyle(.red)
            }
            
            NavigationLink(isActive: $viewModel.isLoggedIn) {
                ChatView(viewModel: ChatViewModel(user: email, service: LocalSocketService.shared))
                    .toolbar(.hidden)
            } label: {
                EmptyView()
            }
        }
    }
}

import Combine

@Observable
class LoginViewModel {
    let service: any AuthenticationService<PasswordAuthentication>
    var isLoggedIn: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(service: any AuthenticationService<PasswordAuthentication>) {
        self.service = service
    }
    
    func logIn(email: String, password: String) {
        service.login(data: .init(email: email, password: password))
            .sink { completion in
                print("logIn completed")
            } receiveValue: { [weak self] isLoggedIn in
                self?.isLoggedIn = isLoggedIn
            }
            .store(in: &cancellables)

    }
}

#Preview {
    LogInView(viewModel: LoginViewModel(service: NullAuthenticationService<PasswordAuthentication>()))
}
