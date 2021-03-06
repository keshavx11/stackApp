//
//  QuestionsViewController.swift
//  stackApp
//
//  Created by Keshav Bansal on 31/05/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit
import CoreData

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GetJsonDelegate {
    
    var manager = GetJson()
    
    func manageTable() {
        self.tableView.reloadData()
        self.endLoad()
    }
    
    var sortParam = "hot"
    var filterParam = ""
    var tagText = ""
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var blurView: UIView!
    
    var tap :UITapGestureRecognizer!
    
    @IBOutlet var searchBar: UISearchBar!
    var searchActive : Bool = false
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
//    var quesArray = NSArray()
    @IBOutlet var sortBtn: UIButton!
    @IBOutlet var filterBtn: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var answeredLabel: UILabel!
    @IBOutlet var answerCountLabel: UILabel!
    
    @IBOutlet var linkBtn: UIButton!
    @IBOutlet var offlineBtn: UIButton!
    
    var currentIndex: Int!
    
    @IBAction func visitLink(){
        
        let dict = manager.quesArray.object(at: currentIndex) as! NSDictionary
        let link = dict.object(forKey: "link") as! String
        UIApplication.shared.open(URL(string:link)!, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func addtoOffline(){
        
        let dict = manager.quesArray.object(at: currentIndex) as! NSDictionary
        let link = dict.object(forKey: "link") as! String
        let title = dict.object(forKey: "title") as! String
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineQuestions")
        request.predicate = NSPredicate(format: "link= %@", link)
        request.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context.fetch(request)
            if results.count > 0 {
                
                let alertController = UIAlertController(
                    title: "Already Added!",
                    message: "The question is already present for offline mode.",
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                let votes = dict.object(forKey: "score") as! NSNumber
                let answers = dict.object(forKey: "answer_count") as! NSNumber
                let onwerName = (dict.object(forKey: "owner") as! NSDictionary).object(forKey: "display_name") as! String
                let answered = dict.object(forKey: "is_answered") as! Bool
                
                let timeResult = dict.object(forKey: "creation_date") as! Double
                let date = NSDate(timeIntervalSince1970: timeResult)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "dd MMM YYYY"
                let dateString = dayTimePeriodFormatter.string(from: date as Date)
                
                let newQues = NSEntityDescription.insertNewObject(forEntityName: "OfflineQuestions", into: context)
                
                newQues.setValue(title, forKey: "title")
                newQues.setValue(votes, forKey: "votes")
                newQues.setValue(answers, forKey: "answers")
                newQues.setValue(onwerName, forKey: "owner")
                newQues.setValue(dateString, forKey: "date")
                newQues.setValue(answered, forKey: "isAnswered")
                newQues.setValue(link, forKey: "link")
                
                do {
                    try context.save()
                }catch{
                    print("There was a problem!")
                }
                
                let alertController = UIAlertController(
                    title: "Saved for offline access!",
                    message: "The question has been saved for offline mode.",
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        }catch{
            print("Fetch Failed")
        }

    }


    func setLoad(){
        self.tableView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
    }
    
    func endLoad(){
        self.activityIndicator.stopAnimating()
        self.tableView.isHidden = false
    }
    
    @IBAction func sort(){
        
        let alertController = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Creation", style: .default, handler: {(action:UIAlertAction) in
            self.setLoad()
            self.sortParam = "creation"
            self.manager.getQuestions(sortParam: self.sortParam, filterParam: self.filterParam, tagText: self.tagText)
        }))
        
        alertController.addAction(UIAlertAction(title: "Votes", style: .default, handler: {(action:UIAlertAction) in
            self.setLoad()
            self.sortParam = "votes"
            self.manager.getQuestions(sortParam: self.sortParam, filterParam: self.filterParam, tagText: self.tagText)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func filter(){
        
        let alertController = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Unanswered", style: .default, handler: {(action:UIAlertAction) in
            self.setLoad()
            self.filterParam = "/unanswered"
            if self.sortParam == "hot"{
                self.sortParam = "votes"
            }
            self.manager.getQuestions(sortParam: self.sortParam, filterParam: self.filterParam, tagText: self.tagText)
        }))
        
        alertController.addAction(UIAlertAction(title: "Featured", style: .default, handler: {(action:UIAlertAction) in
            self.setLoad()
            self.filterParam = "/featured"
            if self.sortParam == "hot"{
                self.sortParam = "votes"
            }
            self.manager.getQuestions(sortParam: self.sortParam, filterParam: self.filterParam, tagText: self.tagText)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        tap = UITapGestureRecognizer(target: self, action:#selector(QuestionsViewController.tapped))
        self.view.addGestureRecognizer(tap)
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
            self.setLoad()
            tagText = String(describing: searchBar.text!)
            manager.getQuestions(sortParam: self.sortParam, filterParam: self.filterParam, tagText: self.tagText)
        }
    }
    
    
    func tapped(){
        
        searchBar.resignFirstResponder()
        view.removeGestureRecognizer(tap)
        
    }
    
    @IBAction func tapDetailExit(){
        
        self.detailView.frame.origin.y = self.view.frame.midX - self.detailView.frame.width/2
        self.detailView.frame.origin.y = self.view.frame.height
        self.blurView.isHidden = true
        self.detailView.isHidden = true
        blurView.removeGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        linkBtn.layer.cornerRadius = 5
        linkBtn.layer.masksToBounds = true
        offlineBtn.layer.cornerRadius = 5
        offlineBtn.layer.masksToBounds = true
        self.detailView.layer.cornerRadius = 7
        self.detailView.layer.masksToBounds = true
        self.detailView.frame.origin.x = self.view.frame.midX - self.detailView.frame.width/2
        self.detailView.frame.origin.y = self.view.frame.height
        detailView.isHidden = false
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.delegate = self
        
        sortBtn.layer.cornerRadius = 5
        sortBtn.layer.masksToBounds = true
        filterBtn.layer.cornerRadius = 5
        filterBtn.layer.masksToBounds = true
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        
        if UserDefaults.standard.value(forKey: "lastFetch") == nil{
            manager.getQuestions(sortParam: self.sortParam, filterParam: self.filterParam, tagText: self.tagText)
        }else{
            manager.quesArray = UserDefaults.standard.object(forKey: "lastFetch") as! NSArray
            self.endLoad()
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if manager.quesArray.count != 0{
            return manager.quesArray.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionCell

        if manager.quesArray.count != 0{
            let dict = manager.quesArray.object(at: indexPath.row) as! NSDictionary
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
        
        currentIndex = indexPath.row
        let dict = manager.quesArray.object(at: indexPath.row) as! NSDictionary
        let title = dict.object(forKey: "title") as! String
        let votes = dict.object(forKey: "score") as! NSNumber
        let answers = dict.object(forKey: "answer_count") as! NSNumber
        let onwerName = (dict.object(forKey: "owner") as! NSDictionary).object(forKey: "display_name") as! String
        if dict.object(forKey: "is_answered") as! Bool == false{
            self.answeredLabel.textColor = UIColor.red
            self.answeredLabel.text = "Unanswered"
        }
            
        let timeResult = dict.object(forKey: "creation_date") as! Double
        let date = NSDate(timeIntervalSince1970: timeResult)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
            
        self.titleLabel.text = title
        self.ownerLabel.text = "Posted by: " + onwerName
        self.voteLabel.text = String(describing: votes)
        self.answerCountLabel.text = "Answers: " + String(describing: answers)
        self.dateLabel.text = "Posted: " + String(describing: dateString)

        self.blurView.isHidden = false
        
        tap = UITapGestureRecognizer(target: self, action:#selector(QuestionsViewController.tapDetailExit))
        self.blurView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.detailView.frame.origin.y = self.view.frame.midY - self.detailView.frame.height/2
            
        })
        
        detailView.isHidden = false
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

