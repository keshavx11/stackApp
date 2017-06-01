//
//  OfflineViewController.swift
//  stackApp
//
//  Created by Keshav Bansal on 31/05/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit
import CoreData

class OfflineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var quesArray = [NSManagedObject]()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    func fetchOffline(){
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineQuestions")
        request.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context.fetch(request)
            if results.count > 0 {
                
                self.quesArray = results as! [NSManagedObject]
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.activityIndicator.stopAnimating()
                
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
            
        }catch{
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text             = "Fetch Failed"
            noDataLabel.textColor        = UIColor.gray
            noDataLabel.textAlignment    = .center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
            self.tableView.isHidden = false
            activityIndicator.startAnimating()
            print("Fetch Failed")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.fetchOffline()
        
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
            let dict = self.quesArray[indexPath.row] 
            let title = dict.value(forKey: "title") as! String
            let votes = dict.value(forKey: "votes") as! NSNumber
            let answers = dict.value(forKey: "answers") as! NSNumber
            let onwerName = dict.value(forKey: "owner") as! String
            if dict.value(forKey: "isAnswered") as! Bool == false{
                cell.answeredLabel.textColor = UIColor.red
                cell.answeredLabel.text = "Unanswered"
            }
            let dateString = dict.value(forKey: "date")
            
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
        let dict = self.quesArray[indexPath.row]
        let title = dict.value(forKey: "title") as! String
        let link = dict.value(forKey: "link") as! String
        
        let alertController = UIAlertController(title: "Select an option", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Visit Question link", style: .default, handler: {(action:UIAlertAction) in
            UIApplication.shared.open(URL(string:link)!, options: [:], completionHandler: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Remove from Offline", style: .default, handler: {(action:UIAlertAction) in
            
            let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineQuestions")
            request.predicate = NSPredicate(format: "link= %@", link)
            request.returnsObjectsAsFaults = false
            
            do{
                
                let results = try context.fetch(request)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                         context.delete(result)
                         
                         do {
                            try context.save()
                            self.fetchOffline()
                            let alertController = UIAlertController(
                                title: "Removed from offline access!",
                                message: "The question has been removed from offline mode.",
                                preferredStyle: .alert)
                            
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                         } catch {
                            print("delete Failed")
                         }
                    }
                }else{
            
                }
                
            }catch{
                print("Fetch Failed")
            }

            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

