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
        
        let url = Config.baseURL.appending(components: "user", user, directoryHint: .notDirectory)
        var request = URLRequest(url: url)
        let base64LoginString = String(format: "%@:%@", user, "pass")
            .data(using: .utf8)!
            .base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error != nil else {
                loggingIn = false
                badLogin = true
                return
            }
            guard let data = data else {
                loggingIn = false
                badLogin = true
                print("Logging in failed: \(String(describing: error))")
                return
            }
            
            let decoder = JSONDecoder()
            currentUser = try! decoder.decode(User.self, from: data)
        }
        task.resume()
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
