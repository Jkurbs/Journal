//
//  ImageResizeOperation.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import ImageIO
import Foundation

class ImageResizeOperation: Operation {
    
    var width: CGFloat
    var height: CGFloat
    var image: UIImage
    
    init(image: UIImage, width: CGFloat, height: CGFloat) {
        self.image = image
        self.width = width
        self.height = height
        super.init()
    }
    
    override func main() {
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(width, height) ]

        if let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
            let newImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
            image = UIImage(cgImage: newImage!)
        }
    }
}
