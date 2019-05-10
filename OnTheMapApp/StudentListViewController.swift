//
//  StudentListViewController.swift
//  OnTheMapApp
//
//  Created by IbrahimGamal on 4/20/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    var appDelegate : AppDelegate!
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if Student.Studentlist.count<100 {
            return Student.Studentlist.count
        }
        else {
            
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell")!
        let student = Student.Studentlist[indexPath.row]
        
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = Student.Studentlist[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        guard let link = URL(string: student.mediaURL ) else {
            return
        }
        // check to see if the url can be opened
        if  UIApplication.shared.canOpenURL(link){
            UIApplication.shared.open(link , options: [:], completionHandler: nil)
        } else {
            let alertVC = UIAlertController(title: "Invalid URL", message: "Problem with loading URL", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    
       
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
       
       loadTableView()
    }
    @IBAction func refresh(_ sender: Any) {
      
        loadTableView()
    }
    
    @IBAction func logoutbtn(_ sender: Any) {
        UdacityAPI.sharedInstance().deleteSessionID()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addPin(_ sender: Any) {
         UdacityAPI.sharedInstance().addLocation(appDelegate: appDelegate,controller : self)
    }
    func loadTableView() {
        
        UdacityAPI.sharedInstance().allStudentsData{(success, error) in
            if success {
                DispatchQueue.main.async {
                   
                    self.tableView.reloadData()
                    
                }
                
            } else {
                
            
                UdacityAPI.sharedInstance().alertMaker(self, error: "There is error in data")
            }
        }
    }
    
    

    
}
