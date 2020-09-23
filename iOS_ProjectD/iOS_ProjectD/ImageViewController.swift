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
    var albumIndex: Int!
    
    let cellIdentifier: String = "imageCell"
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let half: Double = Double(UIScreen.main.bounds.width / 3.0 - 10)
    
    // navigationbar right item button
    var multipleSelectButtonItem: UIBarButtonItem!
    // 과거순(true)/최신순(false) 정렬
    var sortCheck: Bool = false
    // imageCell 터치 시 show되는 것을 막기 위함
    var selectCheck: Bool = false
    // 선택한 이미지 인덱스
    var selectIndex = [Int]()
    
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
    
    //MARK: - barButtonItem 설정
    
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
        selectIndex.removeAll()
        self.navigationItem.title = albumName
        self.collectionView.reloadData()
    }
    
    @IBAction func shareBarButtonAction(_ sender: UIBarButtonItem){
        
        //var assetArray = [PHAsset]()
        var asset = PHAsset()
        var image: UIImage
        var selectedImages: [UIImage] = []
        for i in selectIndex {
            asset = images[i]
            image = getImageFromPHAsset(asset: asset)
            selectedImages.append(image)
        }
        
        
       guard selectedImages.count > 0 else { return }
        
        // UIActivityViewController를 통한 shareAction 구현
        let activityViewController = UIActivityViewController(activityItems: selectedImages, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // 정렬용 navigationBarButtonItem
    @IBAction func sortBarButtonAction(_ sender: UIBarButtonItem){
        
        sortCheck = !sortCheck
        
        if !sortCheck { // 과거순
            sortBarButtonItem.title = "최신순"
            let rvsCreationDateFet = PHFetchOptions()
            rvsCreationDateFet.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            if albumName == "Camera Roll"{
                let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                guard let album: PHAssetCollection = cameraRoll.firstObject else{ return }
                images = PHAsset.fetchAssets(in: album, options: rvsCreationDateFet)
            } else {
                let lstFetchOptions = PHFetchOptions()
                lstFetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
                
                let albumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: lstFetchOptions)
                
                let album: PHAssetCollection = albumList.object(at: albumIndex - 1)
                images = PHAsset.fetchAssets(in: album, options: rvsCreationDateFet)
            }
        } else{ // 최신순
            sortBarButtonItem.title = "과거순"
            let creationDateFet = PHFetchOptions()
            creationDateFet.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            if albumName == "Camera Roll"{
                let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                guard let album: PHAssetCollection = cameraRoll.firstObject else{ return }
                images = PHAsset.fetchAssets(in: album, options: creationDateFet)
            } else{
                let lstFetchOptions = PHFetchOptions()
                lstFetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
                
                let albumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: lstFetchOptions)
                
                let album: PHAssetCollection = albumList.object(at: albumIndex - 1)
                images = PHAsset.fetchAssets(in: album, options: creationDateFet)
            }
        }
        collectionView.reloadData()
    }
    
    @IBAction func trashBarButtonAction(_ sender: UIBarButtonItem){
        var asset = [PHAsset]()
        
        for i in selectIndex {
            asset.append(images[i])
        }
        
        // 삭제 확인 다이얼로그
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(asset as NSArray)}, completionHandler: nil)
        // 삭제 이후 네비게이션바버튼아이템 초기화
        self.actionBarButtonItem.isEnabled = false
        self.trashBarButtonItem.isEnabled = false
        self.navigationItem.hidesBackButton = false
        self.navigationItem.rightBarButtonItem = multipleSelectButtonItem
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.reloadData()
    }
    
    // shareAction을 위한 PHAsset에서 UIImage로 변환 작업
    func getImageFromPHAsset(asset: PHAsset) -> UIImage{
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
            image = result!
        })
        return image
    }
    
    //MARK: - collectionView 설정
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !selectCheck{
            
            guard let nextController = storyboard?.instantiateViewController(withIdentifier: "toDetail" /*Storyboard ID attribute*/) else{
                return
            }
            
            guard let detailView: DetailViewController = nextController as? DetailViewController else{
                return
            }
            
            guard let cell: ImagesCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ImagesCollectionViewCell else {
                return
            }
            detailView.detailImage = cell.imageView.image
            
            detailView.detailAsset = images[indexPath.item]
            self.navigationController?.pushViewController(nextController, animated: true)
        } else{
            if !selectIndex.contains(indexPath.item){
                selectIndex.append(indexPath.item)
            }
            // 다중 선택한 cell 흐리게 함
            collectionView.cellForItem(at: indexPath)?.alpha = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.alpha = 1
        
        if !selectIndex.isEmpty{
            let index: Int! = selectIndex.firstIndex(of: indexPath.item)
            selectIndex.remove(at: index)
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: images) else { return }
        
        images = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
        }
    }
}
