//
//  AlamofireSource.swift
//  Pods
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import Alamofire
import AlamofireImage

public class AlamofireSource: NSObject, InputSource {
    var url: URL
    var imageID : Int
    public init(url: URL, id: Int) {
        self.url = url
        self.imageID = id
        super.init()
    }
    
    public func getId() -> Int {
        return imageID
    }

    public init?(urlString: String, id: Int) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.imageID = id
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        imageView.af_setImage(withURL: self.url, placeholderImage: nil, filter: nil, progress: nil) { (response) in
            imageView.image = response.result.value
            if let value = response.result.value {
                callback(value)
            }
        }
    }
    
}
