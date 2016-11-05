//
//  ZoomablePhotoView.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import UIKit

open class ImageSlideshowItem: UIScrollView, UIScrollViewDelegate {
    
    open let imageView = UIImageView()
    public let captionLabel = UILabel()
    open var deleteDelegate: DeleteDelegate?
    open let image: InputSource
    open var gestureRecognizer: UITapGestureRecognizer?
    
    open let zoomEnabled: Bool
    open let deleteEnabled: Bool
    open var zoomInInitially = false
    
    fileprivate var lastFrame = CGRect.zero
    fileprivate var imageReleased = false
    
    // MARK: - Life cycle
    
    init(image: InputSource, zoomEnabled: Bool, deleteEnabled: Bool) {
        self.zoomEnabled = zoomEnabled
        self.deleteEnabled = deleteEnabled
        self.image = image
        
        super.init(frame: CGRect.null)

        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        captionLabel.numberOfLines = 0
        captionLabel.font = UIFont.systemFont(ofSize: 13)
        captionLabel.textColor = .red
        captionLabel.text = "Apagar"
        
        captionLabel.isUserInteractionEnabled = true
        let labelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(deletePressed))
        captionLabel.addGestureRecognizer(labelTapRecognizer)
        
        setPictoCenter()
        
        // scroll view configuration
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        addSubview(imageView)
        if deleteEnabled {
            addSubview(captionLabel)
        }
        minimumZoomScale = 1.0
        maximumZoomScale = calculateMaximumScale()
        
        // tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageSlideshowItem.tapZoom))
        tapRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapRecognizer)
        gestureRecognizer = tapRecognizer
    }
    
    func deletePressed() {
        if let delegate = deleteDelegate {
            delegate.deletePressed(item: image.getId())
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var imageViewSize = frame.size
                var captionLabelFrame = CGRect()
    
                if deleteEnabled {
                        let captionLabelHeight = ("Apagar" as NSString).boundingRect(with: CGSize(width: frame.size.width-32, height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: captionLabel.font], context: nil).size.height+8
                        imageViewSize = CGSize(width: imageViewSize.width, height: imageViewSize.height-captionLabelHeight)
                        captionLabelFrame = CGRect(x: 8, y: imageViewSize.height, width: frame.size.width-32, height: captionLabelHeight)
                    }
        
                captionLabel.frame = captionLabelFrame
        
        if !zoomEnabled {
            imageView.frame.size = imageViewSize;
        } else if !isZoomed() {
            imageView.frame.size = calculatePictureSize()
            setPictoCenter()
        }
        
        if isFullScreen() {
            clearContentInsets()
        } else {
            setPictoCenter()
        }
        
        // if self.frame was changed and zoomInInitially enabled, zoom in
        if lastFrame != frame && zoomInInitially {
            setZoomScale(maximumZoomScale, animated: false)
        }
        
        lastFrame = self.frame
        
        contentSize = imageView.frame.size
        maximumZoomScale = calculateMaximumScale()
    }

    /// Request to load image to imageView
    func loadImage() {
        if self.imageView.image == nil {
            imageReleased = false
            image.load(to: self.imageView) { image in
                // set image to nil if there was a release request during the image load
                self.imageView.image = self.imageReleased ? nil : image
            }
        }
    }

    func releaseImage() {
        imageReleased = true
        self.imageView.image = nil
    }

    // MARK: - Image zoom & size
    
    func isZoomed() -> Bool {
        return self.zoomScale != self.minimumZoomScale
    }
    
    func zoomOut() {
        self.setZoomScale(minimumZoomScale, animated: false)
    }
    
    func tapZoom() {
        if isZoomed() {
            self.setZoomScale(minimumZoomScale, animated: true)
        } else {
            self.setZoomScale(maximumZoomScale, animated: true)
        }
    }
    
    fileprivate func screenSize() -> CGSize {
        return CGSize(width: frame.width, height: frame.height-captionLabel.frame.size.height)
    }
    
    fileprivate func calculatePictureFrame() {
        let boundsSize: CGSize = bounds.size
        var frameToCenter: CGRect = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    fileprivate func calculatePictureSize() -> CGSize {
        if let image = imageView.image {
            let picSize = image.size
            let picRatio = picSize.width / picSize.height
            let screenRatio = screenSize().width / screenSize().height
            
            if (picRatio > screenRatio){
                return CGSize(width: screenSize().width, height: screenSize().width / picSize.width * picSize.height)
            } else {
                return CGSize(width: screenSize().height / picSize.height * picSize.width, height: screenSize().height)
            }
        } else {
            return CGSize(width: screenSize().width, height: screenSize().height)
        }
    }
    
    fileprivate func calculateMaximumScale() -> CGFloat {
        // maximum scale is fixed to 2.0 for now. This may be overriden to perform a more sophisticated computation
        return 2.0
    }
    
    fileprivate func setPictoCenter(){
        
        var intendHorizon = (screenSize().width - imageView.frame.width ) / 2
        var intendVertical = (screenSize().height - imageView.frame.height ) / 2
        intendHorizon = intendHorizon > 0 ? intendHorizon : 0
        intendVertical = intendVertical > 0 ? intendVertical : 0
        contentInset = UIEdgeInsets(top: intendVertical, left: intendHorizon, bottom: intendVertical, right: intendHorizon)
    }
    
    private func isFullScreen() -> Bool {
        return imageView.frame.width >= screenSize().width && imageView.frame.height >= screenSize().height
    }
    
    func clearContentInsets() {
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: UIScrollViewDelegate
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setPictoCenter()
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomEnabled ? imageView : nil;
    }
    
}
