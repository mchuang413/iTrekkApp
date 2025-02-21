//
//  MapViewWithMarker.swift
//  MyImmersiveApp
//
//  Created by Michael Chuang on 3/9/24.
//

import Foundation

import SwiftUI
import MapKit

struct MapViewWithMarker: View {
    var coordinate: CLLocationCoordinate2D

    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Adjust span for desired zoom level
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: false, annotationItems: [MapAnnotationItem(id: 0, coordinate: coordinate)]) { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
