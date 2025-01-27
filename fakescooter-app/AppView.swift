//
//  AppView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-22.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        if let scoot = reservation {
            ReservedView(scooter: scoot)
        } else if let user = user {
            MapView(
                currentUser: .constant(user),
                reservation: $reservation
            )
        } else {
            LoginView(currentUser: $user)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .background(Color.blue)
        }
    }
    
    @State private var user: User? = nil
    @State private var reservation: Scooter? = nil
}

#Preview {
    AppView()
}
