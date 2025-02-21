import SwiftUI
import AuthenticationServices
import MapKit

struct ContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var immersiveSpaceActive: Bool = false
    @EnvironmentObject private var sharedData: SharedData
    @State private var userPoints: Int = 0
    
    // State for Map view
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    // Changed to @State to update in the view
    @State private var coor: CLLocationCoordinate2D?
    @State private var tappedCoordinates: CLLocationCoordinate2D?
    @State private var submitPressed: Bool = false
    @State private var distance: Double = 0
    @State private var miles: Double = 0
    
    @State private var showMapViewWithMarker = false
    
    @State private var annotationItems: [MapAnnotationItem] = []
    
    let coordinates = CoordinatesData.coordinates
    let locations = LocationsData.locations
    
    @State private var currentText: String = ""
    @State private var animate = false
    @State private var textToShow = ""
    @State private var isDeleting = false
    
    @State private var isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    @State private var userName: String? = UserDefaults.standard.string(forKey: "userName")
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    if isUserLoggedIn {
                        VStack {
                            Text("Welcome, \(userName ?? "User")")
                                .foregroundColor(.white)
                                .onTapGesture {
                                    self.isUserLoggedIn = false
                                    self.userName = nil
                                    UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                                    UserDefaults.standard.removeObject(forKey: "userName")
                                }
                        }
                    } else {
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authResults):
                                    switch authResults.credential {
                                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                        let userName = appleIDCredential.fullName?.givenName ?? "Logout"
                                        UserDefaults.standard.set(userName, forKey: "userName")
                                        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                                        self.userName = userName
                                        self.isUserLoggedIn = true
                                    default:
                                        break
                                    }
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(width: 280, height: 45)
                        .padding()
                    }
                    Text("Points: \(userPoints)")
                        .padding()
                        .background(Color.black.opacity(0.5).cornerRadius(10))
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding([.top, .trailing])
                }
                // The rest of your VStack content remains unchanged
                
                if !immersiveSpaceActive {
                    VStack(spacing: 20) {
                        Text("iTrekk: Trek the Earth")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .padding(.top, 20)
                        
                        Text("Reveal the hidden, one guess at a time...")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        
                        TypingTextView()
                            .font(.largeTitle)
                            .frame(height: 300)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    Task {
                        if !immersiveSpaceActive {
                            let randomIndex = Int.random(in: 0..<coordinates.count)
                            coor = coordinates[randomIndex]
                            sharedData.randomIndex = randomIndex
                            
                            annotationItems = coordinates.enumerated().map { index, coordinate in
                                MapAnnotationItem(id: index, coordinate: coordinate)
                            }
                            
                            await openImmersiveSpace(id: "Environment")
                            immersiveSpaceActive = true
                        } else {
                            await dismissImmersiveSpace()
                            immersiveSpaceActive = false
                            coor = nil
                            submitPressed = false
                            distance = 0
                            miles = 0
                            tappedCoordinates = nil
                        }
                    }
                }) {
                    Text(immersiveSpaceActive ? "Exit Environment" : "View Environment")
                }
                
                if immersiveSpaceActive, let coor = coor {
                    if !submitPressed {
                        CustomMapView(tappedCoordinates: $tappedCoordinates)
                            .edgesIgnoringSafeArea(.all)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        MapViewWithMarker(coordinate: coor)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    if let coordinates1 = tappedCoordinates, !submitPressed {
                        Text("Latitude: \(coordinates1.latitude), Longitude: \(coordinates1.longitude)")
                            .padding()
                            .modifier(CardModifier())
                    }
                    
                    if !submitPressed {
                        Button("Submit") {
                            if let tappedCoordinates = tappedCoordinates {
                                distance = getDistance(c1: coor, c2: tappedCoordinates)
                                miles = distance * 0.00062137
                                submitPressed = true
                                let score = calculateScore(distance: distance)
                                sharedData.addPoints(score)
                                userPoints = sharedData.returnPts()
                            }
                        }
                    }
                    
                    if submitPressed {
                        Text(String(format: "Distance: %.2f meters (%.2f miles)", distance, miles))
                            .font(.largeTitle)
                            .padding()
                            .modifier(ShadowModifier())
                    }
                }
            }
            .padding()
        }
        .onAppear {
            userPoints = sharedData.returnPts()
            isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
            userName = UserDefaults.standard.string(forKey: "userName")
        }
    }
    
}

func calculateScore(distance: Double) -> Int {
    let perfectScoreDistance: Double = 16_093.4 // 10 miles in meters for perfect score
    let veryFarDistance: Double = 500_000 // Example: distance in meters where score becomes 1
    let maxPoints = 5000
    let minPoints = 1

    if distance <= perfectScoreDistance {
        return maxPoints
    } else if distance > perfectScoreDistance && distance <= veryFarDistance {
        // Calculate points for distances between 10 miles and "very far" as a linear decrease
        let score = Double(maxPoints) - ((distance - perfectScoreDistance) / (veryFarDistance - perfectScoreDistance) * Double(maxPoints - minPoints))
        return max(minPoints, Int(score)) // Ensure score doesn't fall below 1
    } else {
        return minPoints
    }
}

func getDistance(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) -> Double {
    let location1 = CLLocation(latitude: c1.latitude, longitude: c1.longitude)
    let location2 = CLLocation(latitude: c2.latitude, longitude: c2.longitude)
    
    return location1.distance(from: location2) // Distance in meters
}

struct MapAnnotationItem: Identifiable {
    let id: Int // Can be any unique identifier
    let coordinate: CLLocationCoordinate2D
}

struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.black.cornerRadius(10).shadow(radius: 5))
            .padding(.horizontal)
    }
}

struct TypingAnimationModifier: AnimatableModifier {
    var step: CGFloat
    var text: String
    
    var animatableData: CGFloat {
        get { step }
        set { step = newValue }
    }
    
    func body(content: Content) -> some View {
        let currentTextIndex = text.index(text.startIndex, offsetBy: Int(step * CGFloat(text.count)))
        let currentText = String(text[..<currentTextIndex])
        return Text(currentText)
            .transition(.opacity)
            .animation(.easeInOut, value: step)
    }
}
