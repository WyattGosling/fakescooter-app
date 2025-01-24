//
//  ContentView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-19.
//

import MapKit
import SwiftUI

struct MapView: View {
    var body: some View {
        Map() {
            ForEach(scooters) { scooter in
                Annotation("\(scooter.batteryLevel)%", coordinate: scooter.location) {
                    Image("kick-scooter")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
        }
    }

    let userLocation = MapCameraPosition.region(
        MKCoordinateRegion(
            center: .init(latitude: 49.26359, longitude: 123.13854),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    let scooters: [Scooter] = [
        .init(id: "abc123", batteryLevel: 99, location: .init(latitude: 49.26227, longitude: -123.14242)),
        .init(id: "def456", batteryLevel: 88, location: .init(latitude: 49.26636, longitude: -123.14226)),
        .init(id: "ghi789", batteryLevel: 77, location: .init(latitude: 49.26532, longitude: -123.13659)),
        .init(id: "jkl012", batteryLevel: 9, location: .init(latitude: 49.26443, longitude: -123.13469))
    ]
}

#Preview {
    MapView()
}
