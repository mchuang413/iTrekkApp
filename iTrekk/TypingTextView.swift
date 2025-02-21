//
//  CustomButtonStyle.swift
//  MyImmersiveApp
//
//  Created by Michael Chuang on 3/10/24.
//

import Foundation
import SwiftUI

struct TypingTextView: View {
    let locations = [
      "London, UK", "Los Angeles, USA", "Shanghai, China", "Moscow, Russia", "Dubai, UAE", "Berlin, Germany", "Singapore, Singapore", "Rome, Italy", "Toronto, Canada", "Mumbai, India",
      "Bangkok, Thailand", "Istanbul, Turkey", "Mexico City, Mexico", "São Paulo, Brazil", "Buenos Aires, Argentina", "Kuala Lumpur, Malaysia", "Seoul, South Korea", "Hong Kong, China", "Barcelona, Spain", "Amsterdam, Netherlands",
      "Vienna, Austria", "Madrid, Spain", "Copenhagen, Denmark", "Lisbon, Portugal", "Budapest, Hungary", "Prague, Czech Republic", "Warsaw, Poland", "Dublin, Ireland", "Athens, Greece", "Helsinki, Finland",
      "Oslo, Norway", "Stockholm, Sweden", "Brussels, Belgium", "Zurich, Switzerland", "Frankfurt, Germany", "Munich, Germany", "Doha, Qatar", "Tel Aviv, Israel", "Beirut, Lebanon", "Kiev, Ukraine",
      "Bucharest, Romania", "Jakarta, Indonesia", "Manila, Philippines", "Hanoi, Vietnam", "Ho Chi Minh City, Vietnam", "Cape Town, South Africa", "Johannesburg, South Africa", "Lagos, Nigeria", "Nairobi, Kenya", "Accra, Ghana",
      "Cairo, Egypt", "Tehran, Iran", "Baghdad, Iraq", "Riyadh, Saudi Arabia", "Lima, Peru", "Santiago, Chile", "Bogotá, Colombia", "Caracas, Venezuela", "Quito, Ecuador", "Montevideo, Uruguay",
      "Panama City, Panama", "Kingston, Jamaica", "Havana, Cuba", "San Juan, Puerto Rico", "Port-au-Prince, Haiti", "Guatemala City, Guatemala", "Managua, Nicaragua", "Tegucigalpa, Honduras", "San Salvador, El Salvador", "Belmopan, Belize",
      "Ottawa, Canada", "Vancouver, Canada", "Calgary, Canada", "Edmonton, Canada", "Winnipeg, Canada", "Montreal, Canada", "Quebec City, Canada", "Halifax, Canada", "St. John's, Canada", "Charlotte, USA",
      "Atlanta, USA", "Miami, USA", "Orlando, USA", "Dallas, USA", "Houston, USA", "Austin, USA", "San Antonio, USA", "Denver, USA", "Las Vegas, USA", "Phoenix, USA",
      "Seattle, USA", "San Francisco, USA", "San Diego, USA", "Los Angeles, USA", "Portland, USA", "Chicago, USA", "Detroit, USA", "Boston, USA", "New York, USA", "Philadelphia, USA"
    ];
    
    @State private var displayedText = ""
    @State private var isDeleting = false
    @State private var currentIndex = Int.random(in: 0..<100) // Updated line
    @State private var showCursor = true
    
    private let typingSpeed: TimeInterval = 0.1
    private let deletingSpeed: TimeInterval = 0.07
    private let pauseDuration: TimeInterval = 2.0
    private let cursorBlinkSpeed: TimeInterval = 0.5

    var body: some View {
        Text("\(displayedText)\(showCursor ? "|" : "")")
            .font(.title)
            .fontWeight(.medium)
            .onAppear {
                blinkCursor()
                typeNextLocation()
            }
    }

    private func typeNextLocation() {
        let location = locations[currentIndex]
        var charIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if charIndex < location.count {
                let index = location.index(location.startIndex, offsetBy: charIndex)
                displayedText.append(location[index])
                charIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    startDeletingText()
                }
            }
        }
    }
    
    private func startDeletingText() {
        var charIndex = displayedText.count
        
        Timer.scheduledTimer(withTimeInterval: deletingSpeed, repeats: true) { timer in
            if charIndex > 0 {
                displayedText.removeLast()
                charIndex -= 1
            } else {
                timer.invalidate()
                currentIndex = (currentIndex + 1) % locations.count
                typeNextLocation()
            }
        }
    }
    
    private func blinkCursor() {
        Timer.scheduledTimer(withTimeInterval: cursorBlinkSpeed, repeats: true) { _ in
            showCursor.toggle()
        }
    }
}
