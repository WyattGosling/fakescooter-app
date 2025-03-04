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
        Api.reserveScooter(
            targetScooter,
            forUser: currentUser,
            onSuccess: { scooter in
                reservation = scooter
                dismiss()
            },
            onAlreadyReserved: {
                Api.getScooter(
                    reservedBy: currentUser,
                    onSuccess: { scooter in
                        reservation = scooter
                        dismiss()
                    },
                    onFailure: { }
                )
            },
            onFailure: { })
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
