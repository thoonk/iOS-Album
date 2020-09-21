//
//  ViewController.swift
//  iOS_ProjectD
//
//  Created by 김태훈 on 2020/09/18.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellIdentifier: String = "cell"
    
    var albumAsset: [PHFetchResult<PHAsset>] = [PHFetchResult<PHAsset>]()
    var assetName: [String] = [String]()
    var assetCount: [Int] = [Int]()
    
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let half: Double = Double(UIScreen.main.bounds.width / 2.0 - 10)
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.albumAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // 앨범 목록의 cell
        let asset: PHAsset = albumAsset[indexPath.item].object(at: 0) // 앨범의 최근 사진

        cell.albumNameLabel.text = assetName[indexPath.item]
        cell.albumCountLabel.text = String(assetCount[indexPath.item])
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: half, height: half), contentMode: .aspectFill, options: nil, resultHandler: {asset, _ in cell.albumImageView?.image = asset})
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 스크롤시 타이틀바에 표시
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "앨범"
        
        // 사진 접근 요청
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가")
            self.requestCollection()
            self.collectionView.reloadData()
        case .denied:
            print("접근 불허")
        case .notDetermined:
            print("아직 응답하지 않음")
            PHPhotoLibrary.requestAuthorization({(status) in
                switch status{
                case .authorized:
                    print("사용자가 하용함")
                    self.requestCollection()
                    
                    OperationQueue.main.addOperation {
                        self.collectionView.reloadData()
                    }
                case .denied:
                    print("사용자가 불허함")
                default: break
                }
            })
        case .restricted:
            print("접근 제한")
        case .limited:
            print("접근 제한")
        @unknown default:
            print("default")
        }
        
//        PHPhotoLibrary.shared().register(self)
        
        // flowlayout 설정
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.sectionInset = UIEdgeInsets.zero
        flowlayout.minimumLineSpacing = 40
        flowlayout.minimumInteritemSpacing = 20
        
        flowlayout.itemSize = CGSize(width: half, height: half + 50)
        
        self.collectionView.collectionViewLayout = flowlayout
    }
    
    func requestCollection(){
//        self.albumAsset = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        guard let cameraRollCollection = cameraRoll.firstObject else{
            return
        }
        
        // 앨범 정렬
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let lstFetchOptions = PHFetchOptions()
        lstFetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
        
        albumAsset.append(PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOptions))
        assetName.append("Camera Roll")
        assetCount.append(albumAsset[0].count)
        
        let albumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: lstFetchOptions)
        let albumCount = albumList.count
        let album: [PHAssetCollection] = albumList.objects(at: IndexSet(0..<albumCount))
        
        // 앨범별 분류해서 저장
        for i in 0..<albumCount{
            albumAsset.append(PHAsset.fetchAssets(in: album[i], options: fetchOptions))
            assetCount.append(albumAsset[i+1].count)
            assetName.append(album[i].localizedTitle!)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "toAlbum" {
            guard let nextController: ImageViewController = segue.destination as? ImageViewController else{
                return
            }
            guard let cell: AlbumCollectionViewCell = sender as? AlbumCollectionViewCell else {
                return
            }
            
            guard let index: IndexPath = self.collectionView.indexPath(for: cell) else{
                return
            }
            
            nextController.images = albumAsset[index.item]
            nextController.albumName = self.assetName[index.item]
            nextController.albumIndex = index.item
        }
    }
}

