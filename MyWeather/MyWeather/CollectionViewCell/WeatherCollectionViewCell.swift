//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by Luke Martin-Resnick on 10/19/20.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    
    func configure(with model: Hour) {
        self.tempLabel.text = "\(model.temp_f)"
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage(named: "sun")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
