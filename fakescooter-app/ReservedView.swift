//
//  ReservedView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-26.
//

import MapKit
import SwiftUI

struct ReservedView: View {
    var body: some View {
        ZStack {
            Map(position: $userLocation, bounds: nil, interactionModes: [.all])
                .mapControls {
                    MapUserLocationButton()
                }
            VStack {
                if reservationCancelledError {
                    // Show a something went wrong box
                    VStack {
                        Text("Something went wrong")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                        Text("You still have the scooter reserved.")
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .shadow(radius: 4.0)
                    .padding()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        stopReservation()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                            .padding(1)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Scooter")
                            .font(.headline)
                        Text(scooter.id)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack {
                        Text(formattedTime)
                            .font(.system(size: 48, design: nil))
                            .onReceive(timer) {_ in
                                formattedTime = formatTimeSpan(start: reservedTime, end: Date())
                            }
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Text("\(scooter.batteryLevel)%")
                            switch scooter.batteryLevel {
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
                        Text("~\(scooter.batteryLevel * 20 / 100) km")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
            }
        }
    }
    
    func formatTimeSpan(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
    
        let components = Calendar.current.dateComponents([.minute, .second], from: start, to: end)
        
        return String(format: "%02d:%02d", components.minute ?? 0, components.second ?? 0)
    }
    
    func stopReservation() {
        Api.unreserveScooter(
            scooter,
            forUser: user,
            onSuccess: onReservationCancelled,
            onFailure: { })
    }
    
    let scooter: Scooter
    let user: User
    let onReservationCancelled: () -> Void
    let reservationCancelledError: Bool = false
    @State private var userLocation = MapCameraPosition.userLocation(
        followsHeading: true,
        fallback: MapCameraPosition.region(
            MKCoordinateRegion(
                center: .init(latitude: 49.26227, longitude: -123.14242),
                span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02))
        )
    )
    @State private var formattedTime: String = "00:00"
    private let reservedTime = Date()
    private let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
}

#Preview {
    ReservedView(
        scooter: .init(
            id: "abc123",
            batteryLevel: 97,
            location: .init(latitude: -123, longitude: 55),
            reserved: true),
        user: .init(id: "abc123", name: "basic"),
        onReservationCancelled: { }
    )
}
