//
//  LPPhotoViewer.swift
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/4/20.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit
//import WebImage
import SDWebImage

private enum StatusBarState: Int
{
    case Show, Hidden
}

enum IndicatorType: Int
{
    case None, NumLabel, PageControl
}

protocol LPPhotoViewerTransitionDelegate: NSObjectProtocol
{
    func genericTrantion(type: LPPhotoViewTransitionType) -> UIViewControllerAnimatedTransitioning?
}

let kLPPhotoViewNotifyName              = "kLPPhotoViewNotifyName"
let kLPPhotoViewNotifyUserInfoIndexKey  = "kLPPhotoViewNotifyUserInfoIndexKey"
let kLPPhotoViewNotifyUserInfoViewKey   = "kLPPhotoViewNotifyUserInfoViewKey"
private let kLPPhotoViewReuseIdentifier = "kLPPhotoViewReuseIdentifier"
private let kLPScreenWidth              = UIScreen.mainScreen().bounds.size.width
private let kLPScreenHeight             = UIScreen.mainScreen().bounds.size.height

class LPPhotoViewer: UIViewController
{
    var customTransition: Bool = false
    
    weak var customTransitionDelegate: LPPhotoViewerTransitionDelegate?
    
    var currentIndex: Int? {
        didSet {
            if currentIndex < 0 {
                currentIndex = 0
            }
            if indicatorType == .NumLabel {
                indicatorLabel.text = imgArr == nil ? "" : "\(currentIndex! + 1)/\(imgArr!.count)"
            } else if indicatorType == .PageControl {
                if CGRectEqualToRect(CGRectZero, pageControl.frame) {
                    pageControl.numberOfPages  = imgArr!.count;
                    let size = pageControl.sizeForNumberOfPages(imgArr!.count)
                    pageControl.frame = CGRectMake(kLPScreenWidth / 2 - size.width / 2, kLPScreenHeight - size.height, size.width, size.height);
                }
                pageControl.currentPage = currentIndex!
            }
        }
    }
    
    var imgArr: [AnyObject]?
    
    var indicatorType: IndicatorType?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self;
        self.modalPresentationStyle = .Custom;
    }
    
    deinit {
        coolDownMemory()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        initViews()
    }
    
    private var statusBarState: StatusBarState? {
        didSet {
            self.prefersStatusBarHidden()
            self.performSelector(#selector(setNeedsStatusBarAppearanceUpdate))
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return !(statusBarState == .Show)
    }
    
    private func initViews() {
        assert(imgArr != nil, "imgArr can not be nil")
        view.addSubview(collectionView)
        collectionView.frame      = UIScreen.mainScreen().bounds
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.registerClass(LPPhotoView.self, forCellWithReuseIdentifier: kLPPhotoViewReuseIdentifier)
        if indicatorType == .NumLabel {
            view.addSubview(indicatorLabel)
        } else if indicatorType == .PageControl {
            view.addSubview(pageControl)
        }
        currentIndex = currentIndex == nil ? 0 : currentIndex
        if currentIndex > 0 {
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex!, inSection:0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        }
    }
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: LPPhotoViewerLayout())
    
    private lazy var indicatorLabel: UILabel = {
        let lb             = UILabel(frame: CGRectMake(0, kLPScreenHeight - 30, kLPScreenWidth, 30))
        lb.backgroundColor = .clearColor()
        lb.textColor       = .whiteColor()
        lb.textAlignment   = .Center
        return lb
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc                = UIPageControl()
        pc.hidesForSinglePage = true
        return pc
    }()
}

extension LPPhotoViewer: UICollectionViewDelegate, UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / kLPScreenWidth + 1) - 1
    }
}

extension LPPhotoViewer: UICollectionViewDataSource, LPPhotoViewDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kLPPhotoViewReuseIdentifier, forIndexPath: indexPath) as! LPPhotoView
        cell.backgroundColor = .clearColor()
        cell.photoViewDelegate = self
        if let imgObj = imgArr?[indexPath.item] {
            if imgObj.isKindOfClass(NSString) {
                let imgStr = imgObj as! String
                if imgStr.hasPrefix("http") || imgStr.hasPrefix("https") {
                    cell.imageURL = NSURL(string: imgObj as! String)
                } else {
                    cell.image = UIImage(named: imgStr)
                }
            } else if imgObj.isKindOfClass(UIImage) {
                cell.image = imgObj as? UIImage
            }
        }
        return cell
    }
    
    func photoViewWillClose(cell: LPPhotoView) {
        NSNotificationCenter.defaultCenter().postNotificationName(kLPPhotoViewNotifyName, object: nil, userInfo: [kLPPhotoViewNotifyUserInfoIndexKey : currentIndex!, kLPPhotoViewNotifyUserInfoViewKey : cell])
        dismissViewControllerAnimated(true, completion: nil)
        statusBarState = .Show
    }
    
    func photoViewWillShow() {
        self.statusBarState = .Hidden
    }
    
    override func didReceiveMemoryWarning() {
        coolDownMemory()
    }
    
    private func coolDownMemory() {
        SDWebImageManager.sharedManager().cancelAll()
        SDWebImageManager.sharedManager().imageCache.clearMemory()
    }
}

class LPPhotoViewerLayout : UICollectionViewFlowLayout
{
    override func prepareLayout() {
        itemSize                                       = UIScreen.mainScreen().bounds.size
        minimumInteritemSpacing                        = 0
        minimumLineSpacing                             = 0
        scrollDirection                                = UICollectionViewScrollDirection.Horizontal
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.pagingEnabled                  = true
        collectionView?.bounces                        = true
    }
}
