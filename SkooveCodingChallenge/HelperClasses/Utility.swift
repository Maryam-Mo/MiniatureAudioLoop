//
//  Utility.swift
//  SkooveCodingChallenge
//
//  Created by Maryam on 5/24/22.
//

import UIKit

class Utility: NSObject {
}

extension UIView {
    func blink() {
        self.alpha = 1.0;
        UIView.animate(withDuration: 0.1,
            delay: 0.0,
                       options: [.curveEaseInOut, .autoreverse],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })
    }

    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 0
    }
    
    func addCornerRadius(rad: CGFloat) {
        let cLayer = self.layer
        cLayer.cornerRadius = rad
        cLayer.masksToBounds = false
        cLayer.rasterizationScale = UIScreen.main.scale
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension CaseIterable where Self: Equatable {
    mutating func next() {
        let allCases = Self.allCases
        guard let selfIndex = allCases.firstIndex(of: self) else { return }
        let nextIndex = Self.allCases.index(after: selfIndex)
        self = allCases[nextIndex == allCases.endIndex ? allCases.startIndex : nextIndex]
    }
}
