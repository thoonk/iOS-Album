//
//  ViewController.swift
//  AsyncExample
//
//  Created by 김태훈 on 2020/09/16.
//  Copyright © 2020 thoonk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func touchUpDownloadButton(_ sender: UIButton){
        
        // https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/LARGE_elevation.jpg/1600px-LARGE_elevation.jpg
        
        guard let imageURL: URL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/LARGE_elevation.jpg/1600px-LARGE_elevation.jpg") else{return}
        
        OperationQueue().addOperation {
            let imageData: Data = try! Data.init(contentsOf: imageURL) // async task
            let image: UIImage = UIImage(data: imageData)!
            
            OperationQueue.main.addOperation {
                self.imageView.image = image
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

