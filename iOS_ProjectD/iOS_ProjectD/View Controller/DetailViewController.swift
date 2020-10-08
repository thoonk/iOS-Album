//
//  DetailViewController.swift
//  iOS_ProjectD
//
//  Created by 김태훈 on 2020/09/22.
//

import UIKit
import Photos

class DetailViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var detailImage: UIImage!
    var detailAsset: PHAsset!

    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageManager.requestImage(for: detailAsset,
                                  targetSize: CGSize(width: detailAsset.pixelWidth, height: detailAsset.pixelHeight),
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: {image, _ in self.imageView.image = image})

        
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 3.0
        
    }
    
    // 네비게이션바 공유 기능 버튼
    @IBAction func shareButtonAction(_ sender: UIBarButtonItem){
        
        let activityItem: [AnyObject] = [self.imageView.image as AnyObject]
        
        // UIActivityViewController를 통한 shareAction 구현
        let activityViewController = UIActivityViewController(activityItems: activityItem, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // 네비게이션바 삭제 기능 버튼
    @IBAction func trashButtonAction(_ sender: UIBarButtonItem){
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets([self.detailAsset] as NSArray)}, completionHandler: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // imageView 줌 기능
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

}
