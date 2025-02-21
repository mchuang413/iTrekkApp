//
//  CustomMapView.swift
//  MyImmersiveApp
//
//  Created by Michael Chuang on 3/7/24.
//

import Foundation
import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var tappedCoordinates: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Deselect the annotation immediately to allow reselection.
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            for view in views {
                view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
            }
        }
        
        @objc func tap(gestureReconizer: UITapGestureRecognizer) {
            let location = gestureReconizer.location(in: gestureReconizer.view)
            if let mapView = gestureReconizer.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                parent.tappedCoordinates = coordinate
            }
        }
        
        
    }
}
