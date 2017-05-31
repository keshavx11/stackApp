//
//  QuestionsViewController.swift
//  stackApp
//
//  Created by Keshav Bansal on 31/05/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var sortParam = "hot"
    var filterParam = ""
    var tagText = ""
    
    @IBOutlet var searchBar: UISearchBar!
    var searchActive : Bool = false
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    var quesArray = NSArray()
    @IBOutlet var sortBtn: UIButton!
    @IBOutlet var filterBtn: UIButton!

    @IBAction func sort(){
        
        let alertController = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Creation", style: .default, handler: {(action:UIAlertAction) in
            self.tableView.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.sortParam = "creation"
            self.getJson()
        }))
        
        alertController.addAction(UIAlertAction(title: "Votes", style: .default, handler: {(action:UIAlertAction) in
            self.tableView.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.sortParam = "votes"
            self.getJson()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func filter(){
        
        let alertController = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Unanswered", style: .default, handler: {(action:UIAlertAction) in
            self.tableView.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.filterParam = "/unanswered"
            if self.sortParam == "hot"{
                self.sortParam = "votes"
            }
            self.getJson()
        }))
        
        alertController.addAction(UIAlertAction(title: "Featured", style: .default, handler: {(action:UIAlertAction) in
            self.tableView.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.filterParam = "/featured"
            if self.sortParam == "hot"{
                self.sortParam = "votes"
            }
            self.getJson()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getJson(){
        
        let urlString = "https://api.stackexchange.com/2.2/questions\(filterParam)?page=1&pagesize=10&order=desc&sort=\(sortParam)&tagged=\(tagText)&site=stackoverflow"
        
        print(urlString)
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: [])
                    
                    let dict = parsedData as! Dictionary<String, Any>
                    
                    self.quesArray = dict["items"] as! NSArray
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
        if searchBar.text != nil{
            self.tableView.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            tagText = String(describing: searchBar.text!)
            getJson()
        }
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        filtered = data.filter({ (text) -> Bool in
//            let tmp: NSString = text
//            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
//        if(filtered.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
//        self.tableView.reloadData()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sortBtn.layer.cornerRadius = 5
        sortBtn.layer.masksToBounds = true
        filterBtn.layer.cornerRadius = 5
        filterBtn.layer.masksToBounds = true
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.getJson()

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
        
        let alertController = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Add to Offline", style: .default, handler: {(action:UIAlertAction) in
            let array = NSMutableArray()
            if UserDefaults.standard.value(forKey: "offline") != nil{
                let arr = (UserDefaults.standard.object(forKey: "offline") as! NSArray).mutableCopy()
                array.addObjects(from: arr as! [AnyObject])
            }
            array.add(dict)
            UserDefaults.standard.set(array as NSMutableArray, forKey: "offline")
            UserDefaults.standard.synchronize()
        }))
        
        alertController.addAction(UIAlertAction(title: "Visit Question link", style: .default, handler: {(action:UIAlertAction) in
            UIApplication.shared.open(URL(string:link)!, options: [:], completionHandler: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
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
