//
//  DOHapticsManager.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 12/17/24.
//

import UIKit

enum HapticType {
    case levelComplete
    case powerUpUsed
    case timeLow
    case gameOver
}

class DOHapticsManager {
    static let shared = DOHapticsManager()
    
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private init() {}
    
    func trigger(_ type: HapticType) {
        switch type {
        case .levelComplete:
            // success notification for ios
            notification.notificationOccurred(.success)
            
        case .powerUpUsed:
            // custom pattern for power-up
            //print("powerup haptic")
            impact.prepare()
            impact.impactOccurred(intensity: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.impact.impactOccurred(intensity: 0.8)
            }
            
        case .timeLow:
            // ticking pattern
            print("lowtime haptic")
            impact.prepare()
            let tickCount = 3
            for i in 0..<tickCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) { [weak self] in
                    self?.impact.impactOccurred(intensity: 0.4)
                }
            }
            
        case .gameOver:
            // strong error pattern
            notification.notificationOccurred(.error)
            impact.prepare()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.impact.impactOccurred(intensity: 1.0)
            }
        }
    }
}
