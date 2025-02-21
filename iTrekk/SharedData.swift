import Foundation

class SharedData: ObservableObject {
    @Published var randomIndex: Int = 0
    @Published var isUserAuthenticated: Bool = false
    @Published var userPoints: Int {
        didSet {
            savePoints(userPoints)
        }
    }
    @Published var userIdentifier: String?

    init() {
        // Initialize userPoints with the value loaded from UserDefaults
        self.userPoints = UserDefaults.standard.integer(forKey: "userPoints")
    }

    func addPoints(_ points: Int) {
        userPoints += points
    }

    func returnPts() -> Int {
        return userPoints
    }
    
    func handleUserSignIn(userIdentifier: String) {
        self.userIdentifier = userIdentifier
        self.isUserAuthenticated = true
        // Optionally fetch or update user points for the logged-in user here
        // This example just reads points from UserDefaults
        self.userPoints = UserDefaults.standard.integer(forKey: "\(userIdentifier)_points")
    }

    private func savePoints(_ points: Int) {
        UserDefaults.standard.set(points, forKey: "userPoints")
        // If you're using userIdentifier to differentiate users, you might want to save it like this:
        // UserDefaults.standard.set(points, forKey: "\(userIdentifier)_points")
    }
}

