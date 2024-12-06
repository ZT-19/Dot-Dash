//
//  DOTimerTrackerService.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 12/6/24.
//

import Foundation
import SpriteKit

class DOTimerTrackerService: NSObject {
    var timesUpCircleTextures:[SKTexture] = [SKTexture]()
    let circleSize: CGSize
    var purple = UIColor(red: 255, green: 0, blue: 255, alpha: 255)
    var lightPurple = UIColor(red: 255, green: 155, blue: 255, alpha: 255)

    private lazy var timerQueue: DispatchQueue = {
        DispatchQueue(label: "com.yourapp.timerQueue")
    }()

    init(circleSize sz: CGSize, completion: @escaping () -> ()) {
        circleSize = sz
        super.init()
        prepareCircleTextures(completion: completion)
    }
func prepareCircleTextures(completion: @escaping () -> ()) {
        let overLayColor: UIColor = lightPurple
        let circleCount: CGFloat = 360.0
        let angleAddition: CGFloat = 2 * .pi / circleCount

        timerQueue.async { [self] in
            var textures = [SKTexture]()
            for i in 1...Int(circleCount) {
                UIGraphicsBeginImageContextWithOptions(circleSize, false, 0)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: circleSize.width / 2.0, y: circleSize.height / 2.0))
                let circleCenter = CGPoint(x: circleSize.width / 2.0, y: circleSize.height / 2.0)
                path.addArc(center: circleCenter,
                            radius: circleSize.width / 2.0,
                            startAngle: -(.pi / 2.0),
                            endAngle: -(.pi / 2.0) + angleAddition * CGFloat(i),
                            clockwise: true)

                let newPath = UIBezierPath(cgPath: path)
                overLayColor.setFill()
                newPath.fill()

                if let image = UIGraphicsGetImageFromCurrentImageContext() {
                    textures.append(SKTexture(image: image))
                }
                UIGraphicsEndImageContext()
            }

            DispatchQueue.main.async {
                self.timesUpCircleTextures = textures.reversed()
                completion()
            }
        }
    }

    func leftOver(percentage: CGFloat) -> [SKTexture] {
        let index = max(0, Int(percentage * CGFloat(timesUpCircleTextures.count)) - 1)
        var list = [SKTexture]()
        for i in index ..< timesUpCircleTextures.count {
            list.append(timesUpCircleTextures[i])
        }
        return list
    }


    func getAllTextures() -> [SKTexture] {
        return timesUpCircleTextures.reversed()
    }
}
