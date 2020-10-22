//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by Luke Martin-Resnick on 10/19/20.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTemplabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    var dayOfWeek = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
//    func configureDay(with model: ForecastDay) -> String {
//        self.dayLabel.textColor = .white
//        self.dayLabel.text = getDayOfWeek(model.date)
//
//        dayOfWeek = self.dayLabel.text!
//        return dayOfWeek
//    }
    
    func getDayOfWeek(_ today: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.date(from: today)!
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    func configure(with model: ForecastDay) {
        
        self.highTempLabel.textAlignment = .center
        self.lowTemplabel.textAlignment = .center
        self.dayLabel.textColor = .white
        self.highTempLabel.textColor = .white
        self.lowTemplabel.textColor = .white
        
        
        
        self.lowTemplabel.text = "\(Int(model.day.mintemp_f))°"
        self.highTempLabel.text = "\(Int(model.day.maxtemp_f))°"
        self.dayLabel.text = getDayOfWeek(model.date)
        //self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.hour[1])!))
        self.iconImageView.contentMode = .scaleAspectFit
        
        let weatherText = model.day.condition.text
        if weatherText.contains("sun") || weatherText.contains("clear") {
            self.iconImageView.image = UIImage(named: "sun")
        } else if weatherText.contains("rain") {
            self.iconImageView.image = UIImage(named: "rain")
        } else {
            self.iconImageView.image = UIImage(named: "cloud")
        }
    }
    
    
    
    
    /*
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Monday
        return formatter.string(from: inputDate)
    }
 */
}
