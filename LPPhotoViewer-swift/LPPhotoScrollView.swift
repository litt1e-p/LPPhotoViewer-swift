//
//  LPPhotoScrollView.swift
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/4/26.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

typealias OneTapCallback = (()->Void)?
typealias DidLoadedImageCallback = (()->Void)?

enum LPPhotoScrollViewContentMode
{
    case ScaleToFit, ScaleToFillForWidth
}

class LPPhotoScrollView: UIScrollView, UIScrollViewDelegate
{
    var imageViewContentMode: LPPhotoScrollViewContentMode = .ScaleToFit
    var oneTapCallback: OneTapCallback
    var didLoadedImageCallback: DidLoadedImageCallback
    
    lazy var imageView:UIImageView = {
        let size                         = self.bounds.size
        let imageView                    = UIImageView(frame: CGRectMake(0, 0, size.width, size.height))
        imageView.userInteractionEnabled = true
        self.addSubview(imageView)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.initGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.initGestures()
    }
    
    private func initGestures() {
        let doubleTap                  = UITapGestureRecognizer(target: self, action: #selector(LPPhotoScrollView.doubleTapEvent(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        let oneTap                     = UITapGestureRecognizer(target: self, action: #selector(LPPhotoScrollView.oneTapEvent))
        oneTap.numberOfTapsRequired    = 1
        oneTap.requireGestureRecognizerToFail(doubleTap)
        self.addGestureRecognizer(oneTap)
    }
    
    func setImage(image:UIImage , size:CGSize = CGSizeZero ) {
        let tempSize      = (size == CGSizeZero) ? image.size : size
        var imageViewSize = tempSize
        if tempSize.width > tempSize.height {
            let ra               = tempSize.height / tempSize.width
            imageViewSize.width  = tempSize.width > self.bounds.width ? self.bounds.width : tempSize.width
            imageViewSize.height = tempSize.width > self.bounds.width ? ra * imageViewSize.width : tempSize.height
        } else if tempSize.width < tempSize.height {
            let ra               = tempSize.height / tempSize.width
            imageViewSize.height = tempSize.height > self.bounds.height ? self.bounds.height : tempSize.height
            imageViewSize.width  = tempSize.height > self.bounds.height ? imageViewSize.height / ra : tempSize.width
        }
        self.layoutIfNeeded()
        self.zoomScale = 1
        
        self.imageView.image       = image
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.frame       = CGRectMake(0, 0, imageViewSize.width,imageViewSize.height)
        self.imageView.startAnimating()
        self.contentSize = imageViewSize
        
        let scrollViewFrame = self.frame
        let scaleWidth      = scrollViewFrame.size.width / imageViewSize.width
        let scaleHeight     = scrollViewFrame.size.height / imageViewSize.height
        var minScale        = scaleWidth
        if self.imageViewContentMode == .ScaleToFit{
            minScale = min(scaleHeight, scaleWidth)
        }
        var maxScale: CGFloat = 1.5
        if imageViewSize.height / self.bounds.height < 4/5 && imageViewSize.height / self.bounds.height > 1/5 {
            maxScale = self.bounds.height / imageViewSize.height
        }
        self.minimumZoomScale = minScale > 1 ? 1:minScale
        self.maximumZoomScale = maxScale
        self.zoomScale        = minScale > 1 ? 1:minScale
        self.centerContentSize()
        self.didLoadedImageCallback?()
    }
    
    private func centerContentSize() {
        let boundSize     = self.bounds.size
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundSize.width {
            contentsFrame.origin.x = (boundSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundSize.height {
            contentsFrame.origin.y = (boundSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        self.imageView.frame = contentsFrame
    }
    
    // MARK: - scrollView delegate
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerContentSize()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - gesture actions
    
    @objc private func doubleTapEvent(sender: UITapGestureRecognizer) {
        let minimumZoomScale = self.minimumZoomScale
        let maximumZoomScale = self.maximumZoomScale
        let boundaryScale    = (maximumZoomScale - minimumZoomScale) / 2.0 + minimumZoomScale
        if boundaryScale > self.zoomScale {
            var point        = sender.locationInView(self)
            point.x         /= self.zoomScale
            point.y         /= self.zoomScale
            var rect         = CGRect()
            rect.size.width  = self.bounds.size.width / maximumZoomScale
            rect.size.height = self.bounds.size.height / maximumZoomScale
            rect.origin.x    = point.x - (rect.size.width  / 2.0)
            rect.origin.y    = point.y - (rect.size.height / 2.0)
            self.zoomToRect(rect, animated: true)
        } else {
            self.setZoomScale(minimumZoomScale, animated: true)
        }
    }
    
    @objc private func oneTapEvent(){
        self.oneTapCallback?()
    }
}
