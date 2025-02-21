//
//  LocationSelectorViewModel.swift
//  MyImmersiveApp
//
//  Created by Michael Chuang on 3/6/24.
//

import Foundation
import MapKit
import SwiftUI

class LocationSelectorViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Example coordinates (Los Angeles, CA)
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        // Function to update the location when the map is tapped
        func updateLocation(coordinate: CLLocationCoordinate2D) {
            // Perform actions with the new coordinate, such as saving it or updating the region center
            print("Tapped location: \(coordinate.latitude), \(coordinate.longitude)")
            // For example, updating the region's center to the tapped location:
            self.region.center = coordinate
        }
    }
