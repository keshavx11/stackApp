//
//  GetJson.swift
//  stackApp
//
//  Created by Keshav Bansal on 01/06/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import Foundation

class GetJson{
    
    var quesArray = NSArray()
    
    var delegate: GetJsonDelegate?
    
    func getQuestions(sortParam: String, filterParam: String, tagText: String){
        
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
                    UserDefaults.standard.set(self.quesArray, forKey: "lastFetch")
                    UserDefaults.standard.synchronize()
                    self.delegate!.manageTable()
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
}

protocol GetJsonDelegate {
    func manageTable()
}
