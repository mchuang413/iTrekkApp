//
//  SharedEnvironmentData.swift
//  MyImmersiveApp
//
//  Created by Michael Chuang on 3/7/24.
//

import Foundation
import MapKit

class SharedEnvironmentData: ObservableObject {
    @Published var selectedEnvironmentCoordinate: CLLocationCoordinate2D?
}
