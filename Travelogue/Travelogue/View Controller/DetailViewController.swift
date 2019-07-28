//
//  DetailViewController.swift
//  Travelogue
//
//  Created by 刘洋 on 7/23/19.
//  Copyright © 2019 Yang Liu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var entry: Entry? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = entry?.title
        contentLabel.text = entry?.content
        if let image = entry?.photo {
            photoImage.image = UIImage(data: image)
        }
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = dateFormatter.string(from: entry!.date!)
    }

}
