//
//  InputSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import UIKit

@objc public protocol InputSource {
    func load(to imageView: UIImageView, with callback: @escaping (_ image: UIImage) -> ())
    func getId() -> Int
}

open class ImageSource: NSObject, InputSource {
    var image: UIImage!
    var imageID : Int
    
    public func getId() -> Int {
        return imageID
    }
    
    public init(image: UIImage, id: Int) {
        self.image = image
        self.imageID = id
    }
    
    public init?(imageString: String, id: Int) {
        if let image = UIImage(named: imageString) {
            self.image = image
            self.imageID = id
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        imageView.image = image
        callback(image)
    }
}
