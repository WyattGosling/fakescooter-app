//  ContentView.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-19.
//

import MapKit

struct Scooter: Codable, Identifiable {
    let id: String
    let batteryLevel: Int
    let location: CLLocationCoordinate2D
    let reservation: Reservation
    
    enum CodingKeys: String, CodingKey {
        case id
        case batteryLevel = "battery"
        case location
        case reservation
    }
}

struct Reservation: Codable {
    let active: Bool
    let startTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case active
        case startTime = "start_time"
    }
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try values.decode(Double.self, forKey: .latitude)
        let lng = try values.decode(Double.self, forKey: .longitude)
        self.init(latitude: lat, longitude: lng)
    }
}
