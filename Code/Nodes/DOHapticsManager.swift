//
//  DOHapticsManager.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 12/17/24.
//

import UIKit

enum DOHapticType {
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
    
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    
    private init() {}
    
    func trigger(_ type: DOHapticType) {
        switch type {
        case .levelComplete:
            // success notification
            notification.notificationOccurred(.success)
            
        case .powerUpUsed:
            // custom pattern for power-up
            // print("powerup haptic")

            softImpact.prepare()
            mediumImpact.prepare()
            rigidImpact.prepare()
            
            // buildup
            softImpact.impactOccurred(intensity: 0.5)
            
            // rising intensity sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in
                self?.mediumImpact.impactOccurred(intensity: 0.7)
            }
            
            // peak impact
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                self?.rigidImpact.impactOccurred(intensity: 1.0)
            }
            
            // falling sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
                self?.mediumImpact.impactOccurred(intensity: 0.6)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { [weak self] in
                self?.softImpact.impactOccurred(intensity: 0.3)
            }
            
        case .timeLow:
            // ticking pattern
            // print("lowtime haptic")
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
