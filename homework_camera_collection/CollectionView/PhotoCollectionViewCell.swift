//
//  PhotoCollectionViewCell.swift
//  homework_camera_collection
//
//  Created by Эльмира Байгулова on 15.05.2022.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    
    func setData(photoCell: PhotoCell) {
        image.image = photoCell.image
        dateLabel.text = photoCell.date
        coordinateLabel.text = photoCell.coordinate
    }
}
