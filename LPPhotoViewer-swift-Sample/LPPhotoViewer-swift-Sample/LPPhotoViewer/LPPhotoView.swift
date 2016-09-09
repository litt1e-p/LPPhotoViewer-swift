//
//  LPPhotoView.swift
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/4/14.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit
//import WebImage
import SDWebImage

protocol LPPhotoViewDelegate: NSObjectProtocol
{
    func photoViewWillClose(cell: LPPhotoView)
    func photoViewWillShow()
}

class LPPhotoView: UICollectionViewCell
{
    weak var photoViewDelegate: LPPhotoViewDelegate?
    
    var imageURL: NSURL? {
        didSet {
            reset()
            activity.startAnimating()
            
            scrollView.imageView.sd_setImageWithURL(imageURL!, placeholderImage: nil, options: SDWebImageOptions.LowPriority, progress: { (receivedSize: Int, expectedSize: Int) in
                
            }) { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) in
                guard error == nil else {print(error); return}
                self.activity.stopAnimating()
                self.scrollView.setImage(image!, size: image!.size)
                if imageURL.absoluteString.hasSuffix(".gif") {
                    SDWebImageManager.sharedManager().cancelAll()
                    SDWebImageManager.sharedManager().imageCache.clearMemory()
                }
            }
            
        }
    }
    
    var image: UIImage? {
        didSet {
            self.scrollView.setImage(image!, size: image!.size)
        }
    }
    
    func reset() {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        contentView.addSubview(scrollView)
        contentView.addSubview(activity)
        activity.center           = contentView.center
        scrollView.oneTapCallback = {[weak self] in
            self?.close()
        }
        scrollView.didLoadedImageCallback = {[weak self] in
            self!.photoViewDelegate?.photoViewWillShow()
        }
    }
    
    func close() {
        photoViewDelegate?.photoViewWillClose(self)
    }
    
    private lazy var scrollView: LPPhotoScrollView = {
        let scrollview = LPPhotoScrollView(frame:CGRect(x:0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        return scrollview
    }()
    
    private lazy var activity: UIActivityIndicatorView =  UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    
}
