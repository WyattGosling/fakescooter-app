//
//  ReservingErrorSheet.swift
//  fakescooter-app
//
//  Created by Wyatt Gosling on 2025-01-27.
//

import SwiftUI

public struct ReservingErrorSheet: View {
    public var body: some View {
        Text("Something went wrong")
            .font(.headline)
        Text("Could not determine is the scooter is still available.")
            .font(.caption)
    }
}

#Preview {
    ReservingErrorSheet()
}
