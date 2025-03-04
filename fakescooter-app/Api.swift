//
//  Api.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-03-02.
//

import Foundation

struct Api {
    static func getUser(name: String, onSuccess: @escaping (User) -> Void, onFailure: @escaping () -> Void) {
        let url = Config.baseURL.appending(
            components: "user", name,
            directoryHint: .notDirectory
        )
        let base64LoginString = String(format: "%@:%@", name, "pass")
            .data(using: .utf8)!
            .base64EncodedString()
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil else {
                print("getUser() error: \(error!)")
                onFailure()
                return
            }
            guard let data = data else {
                print("getUser() no data: \(String(describing: error))")
                onFailure()
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("getScooter(reservedBy:) cannot cast to HTTPURLResponse")
                onFailure()
                return
            }
            guard resp.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? "No data returned"
                print("getScooter(reservedBy:) status code: \(resp.statusCode), \(responseString)")
                onFailure()
                return
            }
            
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(User.self, from: data) {
                onSuccess(user)
            } else {
                onFailure()
            }
        }
        task.resume()
    }
    
    static func getScooter(withId scooterId: String, as user: User, onSuccess: @escaping (Scooter) -> Void, onFailure: @escaping () -> Void) {
        let url = Config.baseURL.appending(
            components: "scooter", scooterId,
            directoryHint: .notDirectory
        )
        let base64LoginString = String(format: "%@:%@", user.name, "pass")
            .data(using: .utf8)!
            .base64EncodedString()

        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil else {
                print("getScooter() error: \(error!)")
                onFailure()
                return
            }
            guard let data = data else {
                print("getScooter() no data: \(String(describing: error))")
                onFailure()
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("getScooter(reservedBy:) cannot cast to HTTPURLResponse")
                onFailure()
                return
            }
            guard resp.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? "No data returned"
                print("getScooter(reservedBy:) status code: \(resp.statusCode), \(responseString)")
                onFailure()
                return
            }
            
            let decoder = JSONDecoder()
            if let scoot = try? decoder.decode(Scooter.self, from: data) {
                onSuccess(scoot)
            } else {
                onFailure()
            }
        }

        task.resume()
    }
    
    static func getScooter(reservedBy user: User, onSuccess: @escaping (Scooter) -> Void, onFailure: @escaping () -> Void) {
        let url = Config.baseURL.appending(
            components: "scooter",
            directoryHint: .notDirectory
        ).appending(queryItems: [
            .init(name: "user", value: user.id)
        ])
        let base64LoginString = String(format: "%@:%@", user.name, "pas")
            .data(using: .utf8)!
            .base64EncodedString()

        var request = URLRequest(url: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil else {
                print("getScooter(reservedBy:) error: \(String(describing: error))")
                onFailure()
                return
            }
            guard let data else {
                print("getScooter(reservedBy:) no data")
                onFailure()
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("getScooter(reservedBy:) cannot cast to HTTPURLResponse")
                onFailure()
                return
            }
            guard resp.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? "No data returned"
                print("getScooter(reservedBy:) status code: \(resp.statusCode), \(responseString)")
                onFailure()
                return
            }
            
            let decoder = JSONDecoder()
            if let scooters = try? decoder.decode([Scooter].self, from: data) {
                print("outputting scooters: \(scooters)")
                onSuccess(scooters[0])
            } else {
                print("could not parse scooter from \(String(data: data, encoding: .utf8) ?? "no data")")
                onFailure()
            }
        }
        
        task.resume()
    }
    
    static func reserveScooter(
            _ scooter: Scooter,
            forUser user: User,
            onSuccess: @escaping (Scooter) -> Void,
            onAlreadyReserved: @escaping () -> Void,
            onFailure: @escaping () -> Void) {
        let url = Config.baseURL.appending(
            components: "scooter", scooter.id,
            directoryHint: .notDirectory
        )
        let base64LoginString = String(format: "%@:%@", user.name, "pas")
            .data(using: .utf8)!
            .base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = try! JSONEncoder().encode(["reserved": true])
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil else {
                print("reserveScooter() error: \(String(describing: error))")
                onFailure()
                return
            }
            guard let data else {
                print("reserveScooter() no data")
                return
            }
            guard let resp = resp as? HTTPURLResponse else {
                print("reserveScooter() cannot cast to HTTPURLResponse")
                return
            }
            if resp.statusCode != 200 {
                let errorString = String(data: data, encoding: .utf8) ?? "no data"
                if errorString == "user \(user.name) already has a scooter reserved\n" {
                    onAlreadyReserved()
                    return
                }
            }

            let decoder = JSONDecoder()
            if let scooter = try? decoder.decode(Scooter.self, from: data) {
                onSuccess(scooter)
            } else {
                onFailure()
            }
        }
        task.resume()
    }
}
