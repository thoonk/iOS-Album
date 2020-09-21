//
//  ImageViewController.swift
//  iOS_ProjectD
//
//  Created by 김태훈 on 2020/09/20.
//

import UIKit
import Photos

class ImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var sortBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    

    var images: PHFetchResult<PHAsset>!
    var albumName: String?
    var albumIndex: Int?
    
    let cellIdentifier: String = "imageCell"
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let half: Double = Double(UIScreen.main.bounds.width / 3.0 - 10)
    
    // navigationbar right item button
    var multipleSelectButtonItem: UIBarButtonItem!
    // imageCell 터치 시 show되는 것을 막기 위함
    var selectCheck: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: half, height: half)
        flowlayout.sectionInset = UIEdgeInsets.zero
        flowlayout.minimumLineSpacing = 10
        flowlayout.minimumInteritemSpacing = 10
        self.collectionView.collectionViewLayout = flowlayout
        
        self.navigationItem.title = albumName
        // 큰 타이틀 X
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        // 포토 라이브러리 변화시 적용
        PHPhotoLibrary.shared().register(self)
        
        multipleSelectButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectAction(_:)))
        
        self.navigationItem.rightBarButtonItem = multipleSelectButtonItem
    }
    
    // 네비게이션바 선택 버튼
    @objc func selectAction(_ sender: UIBarButtonItem) -> Void{
        self.selectCheck = true
        self.actionBarButtonItem.isEnabled = true
        self.trashBarButtonItem.isEnabled = true
        self.navigationItem.title = "항목선택"
        self.navigationItem.hidesBackButton = true
        // 선택 취소
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction(_:)))
        
        self.collectionView.allowsMultipleSelection = true
    }
    
    // 네비게이션바 선택 터치 시 취소 버튼
    @objc func cancelAction(_ sender: UIBarButtonItem) -> Void{
        self.selectCheck = false
        self.actionBarButtonItem.isEnabled = false
        self.trashBarButtonItem.isEnabled = false
        self.navigationItem.title = "선택"
        self.navigationItem.hidesBackButton = false
        self.navigationItem.rightBarButtonItem = multipleSelectButtonItem
        
        self.collectionView.allowsMultipleSelection = false
        
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ImagesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ImagesCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        let image: PHAsset = images.object(at: indexPath.item)
        
        imageManager.requestImage(for: image, targetSize: CGSize(width: half, height: half), contentMode: .aspectFill, options: nil, resultHandler: {image,  _ in
            cell.imageView?.image = image
        })
        
//        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: images) else { return }
        
        images = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.collectionView.reloadSections(IndexSet(0...0))
        }
    }
   

}
