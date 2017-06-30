//
//  PictureCell.swift
//  Instagram
//
//  Created by 冒亚东 on 2017/6/9.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = UIScreen.main.bounds.width
        picImg.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
}
