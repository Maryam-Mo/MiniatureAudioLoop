//
//  CustomSlider.swift
//  SkooveCodingChallenge
//
//  Created by Maryam on 5/20/22.
//

import Foundation
import UIKit

@IBDesignable
class CustomSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 156
    @IBInspectable var thumbRadius: CGFloat = 8

    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = UIColor.init(hexString: "A7CDFF")
        thumb.layer.borderWidth = 1
        thumb.layer.borderColor = UIColor.init(hexString: "49a1ff").cgColor
        return thumb
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
        
    }

    private func thumbImage(radius: CGFloat) -> UIImage {

        thumbView.frame = CGRect(x: 0, y: radius/2, width: radius, height: trackHeight)
        thumbView.layer.cornerRadius = radius / 2

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    func changeThumbImageSize(radius: CGFloat) {
        let thumb = thumbImage(radius: radius)
        setThumbImage(thumb, for: .normal)
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        newRect.size.width = bounds.width
        newRect.origin.y = 0
        return newRect
    }
    
}
