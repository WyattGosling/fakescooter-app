//  ContentView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-19.
//

import MapKit

struct Scooter: Identifiable {
    let id: String
    let batteryLevel: Int
    let location: CLLocationCoordinate2D
}
