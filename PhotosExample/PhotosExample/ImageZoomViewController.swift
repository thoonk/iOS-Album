//
//  ImageZoomViewController.swift
//  PhotosExample
//
//  Created by 김태훈 on 2020/09/17.
//  Copyright © 2020 thoonk. All rights reserved.
//

import UIKit
import Photos

class ImageZoomViewController: UIViewController, UIScrollViewDelegate  {
    
    var asset: PHAsset!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    @IBOutlet weak var imageView: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: {image, _ in self.imageView.image = image})
    }
    
    
    
    
}
