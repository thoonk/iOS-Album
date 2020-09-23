//
//  DetailViewController.swift
//  iOS_ProjectD
//
//  Created by 김태훈 on 2020/09/22.
//

import UIKit
import Photos

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var detailImage: UIImage!
    var detailAsset: PHAsset!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = detailImage
        
    }
    
    @IBAction func trashButtonAction(_ sender: UIBarButtonItem){
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets([self.detailAsset] as NSArray)}, completionHandler: nil)
        
        self.navigationController?.popViewController(animated: true)
    }

 

}
