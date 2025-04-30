//
//  LoginView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-22.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            Image("background-blue")
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
                        usernameIsFocused = false
                        passwordIsFocused = true
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
                    .font(.largeTitle)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 410)
                SecureField("password", text: $password)
                    .focused($passwordIsFocused)
                    .onSubmit {
                        login(as: username)
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
                    .font(.largeTitle)
                    .padding(.horizontal, 410)
                    .padding(.bottom, 16)
                if loggingIn {
                    ProgressView()
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
    }
    
    func login(as user: String) {
        guard !loggingIn else { return }
        
        loggingIn = true
        badLogin = false
        
        Api.getUser(
            name: user,
            onSuccess: { user in
                Api.getScooter(
                    reservedBy: user,
                    onSuccess: { scooter in
                        foundScooter = scooter
                        foundUser = user
                        loggingIn = false
                    },
                    onFailure: {
                        foundUser = user
                        loggingIn = false
                    }
                )
            },
            onFailure: {
                loggingIn = false
                badLogin = true
            }
        )
    }
    
    @Binding var foundUser: User?
    @Binding var foundScooter: Scooter?
    @State private var badLogin: Bool = false
    @State private var loggingIn: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var usernameIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
}

#Preview {
    LoginView(foundUser: .constant(nil), foundScooter: .constant(nil))
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
}
