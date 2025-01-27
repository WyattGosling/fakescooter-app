//
//  ReservedView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-26.
//

import SwiftUI

struct ReservedView: View {
    var body: some View {
        // placeholder
        VStack {
            Text("Reservation Info")
                .font(.headline)
            Text("id: \(scooter.id)")
            Text("battry: \(scooter.batteryLevel)%")
            Text("latitude: \(scooter.location.latitude)")
            Text("longitude: \(scooter.location.longitude)")
        }
    }
    
    let scooter: Scooter
}

#Preview {
    ReservedView(scooter: .init(
        id: "abc123",
        batteryLevel: 97,
        location: .init(latitude: 123, longitude: 55),
        reserved: true)
    )
}
