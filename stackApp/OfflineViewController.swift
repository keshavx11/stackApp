//
//  OfflineViewController.swift
//  stackApp
//
//  Created by Keshav Bansal on 31/05/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

class OfflineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var quesArray = NSMutableArray()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        let array = NSMutableArray()
        if UserDefaults.standard.object(forKey: "offline") != nil{
            let arr = (UserDefaults.standard.object(forKey: "offline") as! NSArray).mutableCopy()
            array.addObjects(from: arr as! [AnyObject])
            quesArray = array
            self.tableView.isHidden = false
            activityIndicator.startAnimating()
        }else{
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text             = "No questions added to Offline view"
            noDataLabel.textColor        = UIColor.gray
            noDataLabel.textAlignment    = .center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
            self.tableView.isHidden = false
            activityIndicator.startAnimating()

        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.quesArray.count != 0{
            return self.quesArray.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionCell
        
        if self.quesArray.count != 0{
            let dict = self.quesArray.object(at: indexPath.row) as! NSDictionary
            let title = dict.object(forKey: "title") as! String
            let votes = dict.object(forKey: "score") as! NSNumber
            let answers = dict.object(forKey: "answer_count") as! NSNumber
            let onwerName = (dict.object(forKey: "owner") as! NSDictionary).object(forKey: "display_name") as! String
            if dict.object(forKey: "is_answered") as! Bool == false{
                cell.answeredLabel.textColor = UIColor.red
                cell.answeredLabel.text = "Unanswered"
            }
            
            let timeResult = dict.object(forKey: "creation_date") as! Double
            let date = NSDate(timeIntervalSince1970: timeResult)
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "dd MMM YYYY"
            let dateString = dayTimePeriodFormatter.string(from: date as Date)
            
            cell.titleLabel.text = title
            cell.ownerLabel.text = "Posted by: " + onwerName
            cell.questionNoLabel.text = String(indexPath.row + 1)
            cell.voteLabel.text = "Votes: " + String(describing: votes)
            cell.answerCountLabel.text = "Answers: " + String(describing: answers)
            cell.dateLabel.text = "Posted: " + String(describing: dateString)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.quesArray.object(at: indexPath.row) as! NSDictionary
        let link = dict.object(forKey: "link") as! String
        
        UIApplication.shared.open(URL(string:link)!, options: [:], completionHandler: nil)

        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //    func hexStringToUIColor (_ hex:String) -> UIColor {
    //        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    //
    //        if (cString.hasPrefix("#")) {
    //            let index1 = cString.characters.index(cString.endIndex, offsetBy: -(cString.characters.count-1))
    //            cString = cString.substring(from: index1)
    //        }
    //
    //        if (cString.characters.count != 6) {
    //            return UIColor.gray
    //        }
    //
    //        var rgbValue:UInt32 = 0
    //        Scanner(string: cString).scanHexInt32(&rgbValue)
    //
    //        return UIColor(
    //            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
    //            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
    //            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
    //            alpha: CGFloat(1.0)
    //        )
    //    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

