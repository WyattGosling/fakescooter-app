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
        }
    }
    
    func login(as user: String) {
        guard !loggingIn else { return }
        
        loggingIn = true
        
        let url = URL(string: "http://localhost:8080/user/\(user)")!
        var request = URLRequest(url: url)
        let base64LoginString = String(format: "%@:%@", user, "pass")
            .data(using: .utf8)!
            .base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                loggingIn = false
                print("Logging in failed. Do some error handling wyatt")
                return
            }
            
            let decoder = JSONDecoder()
            print(String(decoding: data, as: UTF8.self))
            currentUser = try! decoder.decode(User.self, from: data)
        }
        task.resume()
    }
    
    @Binding var currentUser: User?
    @State private var username: String = ""
    @State private var loggingIn: Bool = false
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
