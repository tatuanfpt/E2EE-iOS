//
//  ConversationView.swift
//  MessagingApp
//
//  Created by Sam on 22/5/25.
//

import SwiftUI

struct ConversationView: View {
    @Bindable var viewModel: ConversationViewModel
    @State private var isActive: Bool = false
    
    init(viewModel: ConversationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.users) { user in
            NavigationLink(isActive: $isActive) {
                ChatView(viewModel: ChatViewModel(sender: viewModel.sender, receiver: user.username, service: LocalSocketService.shared))
                    .toolbar(.hidden)
            } label: {
                Text(user.username)
                    .onTapGesture {
                        isActive = true
                    }
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}

import Combine
@Observable
class ConversationViewModel {
    var users: [User] = []
    var sender: String
    
    private let service: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    init(sender: String, service: UserService) {
        self.sender = sender
        self.service = service
    }
    
    func fetchUsers() {
        service.fetchUsers()
            .sink { completion in
                
            } receiveValue: { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)

    }
}

#Preview {
    ConversationView(viewModel: ConversationViewModel(sender: "", service: NullUserService()))
}
