//
//  ReservingSheet.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-27.
//

import SwiftUI

struct ReservingSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("Scooter")
                Spacer()
                switch targetScooter.batteryLevel {
                case 95...100:
                    Image(systemName: "battery.100percent")
                case 70..<95:
                    Image(systemName: "battery.75percent")
                case 45..<70:
                    Image(systemName: "battery.50percent")
                case 20..<45:
                    Image(systemName: "battery.25percent")
                default:
                    Image(systemName: "battery.0percent")
                    
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Text("30m:")
                    Text("Free")
                        .frame(minWidth: 50, maxWidth: 50)
                        .background(Color.green.opacity(0.2))
                }
                HStack {
                    Spacer()
                    Text("After:")
                    Text("30¢/m")
                }
            }
            if alreadyReserved {
                Button(action: reserve) {
                    Spacer()
                    Text("Already Reserved")
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .disabled(true)
            } else {
                Button(action: reserve) {
                    Spacer()
                    Text("Reserve Now")
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    func reserve() {
        // Oh hey, it is this code again
        let base64LoginString = String(format: "%@:%@", currentUser.name, "pas")
            .data(using: .utf8)!
            .base64EncodedString()
        
        let url = Config.baseURL.appending(
            components: "scooter", targetScooter.id,
            directoryHint: .notDirectory
        )
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = try! JSONEncoder().encode(["reserved": true])
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil else {
                print("Error reserving scooter: \(String(describing: error))")
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("Error with the url response")
                return
            }
            guard let data else {
                print("Error reserving scooter: \(String(describing: error))")
                return
            }
            
            if resp.statusCode != 200 {
                let errorString = String(data: data, encoding: .utf8) ?? "no data"
                if errorString == "user \(currentUser.name) already has a scooter reserved" {
                    lookupExistingReservation();
                    dismiss()
                }
            }

            let decoder = JSONDecoder()
            let scooter = try! decoder.decode(Scooter.self, from: data)
            reservation = scooter
            dismiss()
        }
        task.resume()
    }

    /*
     * A request responded stating the current user already has a reservation.
     * Lookup that reservation and set states accordingly.
     */
    func lookupExistingReservation() {
        // Oh hey, it is this code again
        let base64LoginString = String(format: "%@:%@", currentUser.name, "pas")
            .data(using: .utf8)!
            .base64EncodedString()
        
        let url = Config.baseURL.appending(
            components: "scooter",
            directoryHint: .notDirectory
        ).appending(queryItems: [
            .init(name: "user", value: currentUser.id)
        ])

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil else {
                print("Error reserving scooter: \(String(describing: error))")
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("Error with the url response")
                return
            }
            guard let data else {
                print("Error reserving scooter: \(String(describing: error))")
                return
            }
            guard resp.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? "No data returned"
                print("Error reserving scooter: \(resp.statusCode), \(responseString)")
                return
            }
            
            let decoder = JSONDecoder()
            let scooter = try! decoder.decode(Scooter.self, from: data)
            reservation = scooter
        }
    }
    
    @Binding var alreadyReserved: Bool
    @Binding var currentUser: User
    @Binding var reservation: Scooter?
    @Binding var targetScooter: Scooter
}

#Preview {
    ReservingSheet(
        dismiss: .init(\.dismiss),
        alreadyReserved: .constant(false),
        currentUser: .constant(.init(id: "123", name: "demo")),
        reservation: .constant(nil),
        targetScooter: .constant(.init(id: "def345", batteryLevel: 89, location: .init(latitude: 1, longitude: 2), reserved: false)))
}
