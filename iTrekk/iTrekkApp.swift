import SwiftUI
import MapKit

@main
struct iTrekkApp: App {
//    @StateObject var viewModel = AuthViewModel()
    //Select immersionStyle
    @State private var immersionStyle: ImmersionStyle = .full //For example you also can use .mixed for a mixed ImmersionStyle
    @StateObject private var sharedData = SharedData()
    
    var body: some Scene {
        WindowGroup {
            //Starting Window to control entry in the ImmersiveSpace
            ContentView()
                .environmentObject(sharedData)
        }
        ImmersiveSpace(id: "Environment") {
            let initialRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), latitudinalMeters: 6000, longitudinalMeters: 6000)
            //struct with the RealityView
            ImmersiveView(index: sharedData.randomIndex + 1)
//            LocationSelectorView(viewModel: LocationSelectorViewModel(initialRegion: initialRegion))
        }.immersionStyle(selection: $immersionStyle, in: .full)
    }
}
