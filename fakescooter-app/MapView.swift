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
                        .onTapGesture {
                            onScooterTap(scooter)
                        }
                }
            }
        }
        .sheet(isPresented: $shouldShowReservationDialog) {
            selectedScooter = nil
            alreadyReserved = false
            problemRefreshingScooter = false
        } content:{
            if problemRefreshingScooter {
                ReservingErrorSheet()
                    .padding()
                    .presentationDetents([.fraction(0.20)])
            } else {
                ReservingSheet(
                    alreadyReserved: $alreadyReserved,
                    currentUser: $currentUser,
                    reservation: $reservation,
                    targetScooter: .constant(selectedScooter!)
                )
                .padding()
                .presentationDetents([.fraction(0.20)])
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
        .init(id: "abc123", batteryLevel: 99, location: .init(latitude: 49.26227, longitude: -123.14242), reserved: false),
        .init(id: "def456", batteryLevel: 88, location: .init(latitude: 49.26636, longitude: -123.14226), reserved: false),
        .init(id: "ghi789", batteryLevel: 77, location: .init(latitude: 49.26532, longitude: -123.13659), reserved: false),
        .init(id: "jkl012", batteryLevel: 9, location: .init(latitude: 49.26443, longitude: -123.13469), reserved: false)
    ]
    
    func onScooterTap(_ scooter:  Scooter) {
        // This should really be put somewhere as it shouldn't in every
        // handler that needs to do an API request. But where that should
        // be, I've yet to determine.
        let base64LoginString = String(format: "%@:%@", currentUser.name, "pass")
            .data(using: .utf8)!
            .base64EncodedString()
        
        let url = Config.baseURL.appending(
            components: "scooter", scooter.id,
            directoryHint: .notDirectory
        )
        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print("request failed: \(String(describing: error))")
                return
            }
            
            let decoder = JSONDecoder()
            let scoot = try? decoder.decode(Scooter.self, from: data)
            
            if let scoot = scoot {
                if scoot.reserved {
                    alreadyReserved = true
                }
            } else {
                problemRefreshingScooter = true
            }
        }

        task.resume()
        
        selectedScooter = scooter
        shouldShowReservationDialog = true
    }

    @Binding var currentUser: User
    @Binding var reservation: Scooter?
    @State var alreadyReserved: Bool = false
    @State var problemRefreshingScooter: Bool = false
    @State var shouldShowReservationDialog: Bool = false
    @State var selectedScooter: Scooter? = nil
}

#Preview {
    MapView(
        currentUser: .constant(User(id: "abc123", name: "basic")),
        reservation: .constant(nil)
    )
}
