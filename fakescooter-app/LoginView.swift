//
//  LoginView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-22.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Text("Fakescooter")
                .font(.largeTitle.smallCaps())
                .fontWeight(.bold)
                .colorInvert()
            Image("kick-scooter")
                .resizable()
                .frame(width: 120, height: 120)
                .colorInvert()
            TextField("username", text: $username)
                .focused($usernameIsFocused)
                .onAppear() {
                    usernameIsFocused = true
                }
                .onSubmit {
                    login(as: username)
                }
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.center)
                .disableAutocorrection(true)
                .background(Color.white)
                .border(.primary)
                .font(.largeTitle)
                .padding()
            if loggingIn {
                ProgressView()
                    .colorInvert()
            }
            if badLogin {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1, green: 0.88, blue: 0.88))
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: 300, height: 40)
                    Text("Incorrect username.")
                        .bold()
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    func login(as user: String) {
        guard !loggingIn else { return }
        
        loggingIn = true
        badLogin = false
        
        Api.getUser(
            name: user,
            onSuccess: { user in
                loggingIn = false
                currentUser = user
            },
            onFailure: {
                loggingIn = false
                badLogin = true
            }
        )
    }
    
    @Binding var currentUser: User?
    @State private var badLogin: Bool = false
    @State private var loggingIn: Bool = false
    @State private var username: String = ""
    @FocusState private var usernameIsFocused: Bool
}

#Preview {
    LoginView(currentUser: .constant(nil))
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
        .background(Color.blue)
}
