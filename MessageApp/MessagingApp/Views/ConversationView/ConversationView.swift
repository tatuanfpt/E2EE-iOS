//
//  ConversationView.swift
//  MessagingApp
//
//  Created by Sam on 22/5/25.
//

import SwiftUI

struct ConversationView: View {
    @Bindable var viewModel: ConversationViewModel
    
    init(viewModel: ConversationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("\(viewModel.sender)")
            List(viewModel.users) { user in
                HStack {
                    Text(user.username)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.select(user: user)
                }
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
        .navigationTitle("Conversation")
    }
}

import Combine
@Observable
class ConversationViewModel {
    var users: [User] = []
    var sender: String
    
    private let service: UserService
    private var cancellables: Set<AnyCancellable> = []
    private let didTapItem: (String, String) -> Void
    
    init(sender: String, service: UserService, didTapItem: @escaping (String, String) -> Void) {
        self.sender = sender
        self.service = service
        self.didTapItem = didTapItem
    }
    
    func fetchUsers() {
        service.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    //TODO: -show error state
                    print("❌ fetchUsers failed")
                case .finished: break
                }
            } receiveValue: { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)

    }
    
    func select(user: User) {
        didTapItem(sender, user.username)
    }
}

#Preview {
    ConversationView(viewModel: ConversationViewModel(sender: "", service: NullUserService(), didTapItem: { _, _ in }))
}
