//
//  UdacityAPI.swift
//  OnTheMapApp
//
//  Created by IbrahimGamal on 4/21/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
import UIKit
class UdacityAPI : NSObject
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override init() {
        super.init()
    }
    
    
    
    func UdacityLogin(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool,_ errormsg: String?, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://onthemap-api.udacity.com/v1/session")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String, errormsg: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForAuth(false, errormsg, NSError(domain: "getUdacityData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error :"No Data Was Returned By The Request!" ,errormsg: "Network Connection Is Offline!")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!", errormsg: "Invalid Email Or Password!")
                return
            }
            
            guard let data = data else {
                sendError(error: "No Data Was Returned By The Request!", errormsg: "Network Connection Is Offline!")
                return
            }
            
            //Parse Data
            
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            
            let stringnewData = String(data: newData, encoding: .utf8)!
            print(stringnewData)
            
            let parsedResult = try? JSONSerialization.jsonObject(with: newData, options: .allowFragments)
            
            guard let dictionary = parsedResult as? [String: Any] else {
                sendError(error: "Can't Parse Dictionary", errormsg: "Network Connection Is Offline!")
                return
            }
           
            
            guard let session = dictionary["session"] as? [String:Any] else {
                sendError(error: "Cannot Find session id In \(String(describing: parsedResult))", errormsg: "Network Connection Is Offline!")
                return
            }
            
            guard let sessionID = session["id"] as? String else {
                sendError(error: "Cannot Find ID In \(session)", errormsg: "Network Connection Is Offline!")
                return
            }
            
            self.appDelegate.sessionId = sessionID
            //Utilize Data
            
            guard let account = dictionary["account"] as? [String:Any] else {
                sendError(error: "Cannot Find Key 'Account' In \(String(describing: parsedResult))", errormsg: "Network Connection Is Offline!")
                return
            }
            guard let key = account["key"] as? String else {
                sendError(error: "Cannot Find Key 'Key' In \(account)", errormsg: "Network Connection Is Offline!")
                return
            }
            
            self.appDelegate.userID = key
            
            completionHandlerForAuth(true, nil, nil)
        }
        
        task.resume()
        
    }
    
    
    func SingleStudentData(userID: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://onthemap-api.udacity.com/v1/users/\(userID)")! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForAuth(false, NSError(domain: "getUserData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
            
            //Parse Data
            
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
            } catch {
                sendError(error: "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                sendError(error: "Cannot Parse")
                return
            }
            
            
         
            guard let lastName = dictionary["last_name"] as? String else {
                sendError(error: "Cannot Find last_name In \(dictionary)")
                return
            }
            
            //Utilize Data
            
            guard let firstName = dictionary["first_name"] as? String else {
                sendError(error: "Cannot Find first_name In \(dictionary)")
                return
            }
            guard let key = dictionary["key"] as? String else {
                sendError(error: "Cannot Find Key  In \(dictionary)")
                return
            }
            //guard let objectId = dictionary["objectId"] as? String else {
            //    sendError(error: "Cannot Find Key 'objectId' In \(dictionary)")
           //     return
           // }
            
            self.appDelegate.lastName = lastName
            self.appDelegate.firstName = firstName
             self.appDelegate.uniqueKey = key
           // self.appDelegate.objectId = objectId
            
            completionHandlerForAuth(true, nil)
        }
        task.resume()
    }
    
    func allStudentsData(completionHandlerForData: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt&limit=100")! as URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForData(false, NSError(domain: "getStudentData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
            
            //Parse Data
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                sendError(error: "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            if let results = parsedResult as? [String: Any] {
                if let resultSet = results["results"] as? [[String: Any]]{
                    
                    for result in resultSet {
                        if let StudentInfo = Student(dictionary: result) {
                            Student.Studentlist.append(StudentInfo)
                        }
                    }
                    
                    completionHandlerForData(true, nil)
                }
            } else {
                sendError(error: "Sorry! Edit!")
            }
            
        }
        task.resume()
    }
    func updateStudentData(student: Student, location: String, completionHandlerForPut: @escaping (_ success: Bool, _ error: NSError?)->Void) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(student.objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPut(false, NSError(domain: "updateStudentData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard data != nil else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
            completionHandlerForPut(true, nil)
        }
        task.resume()
        
    }
    
    func postNewStudent(student: Student, location: String, completionHandlerForPost: @escaping (_ success: Bool, _ error: NSError?)->Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")! as URL)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(false, NSError(domain: "postNew", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            
            guard data != nil else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
        
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            } catch {
                sendError(error: "Could Not Parse The Data As JSON: '\(String(describing: data))'")
                return
            }
            guard let dictionary = parsedResult as? [String: Any] else {
                sendError(error: "Cannot Parse")
                return
            }
            
            
            guard let objectId = dictionary["objectId"] as? String else {
                print( "Cannot Find Key 'objectId' In \(dictionary)")
                return
            }
            
            self.appDelegate.objectId=objectId
            
            print("object id = "+objectId)
            
            self.appDelegate.objectId = dictionary["objectId"] as! String;
            completionHandlerForPost(true, nil)
        }
        task.resume()
        
    }
    
    
    
    
    func deleteSessionID() {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://onthemap-api.udacity.com/v1/session")! as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard data != nil else {
                print("No Data Was Returned By The Request!")
                return
            }
           
        }
        task.resume()
    }
    
    func alertMaker(_ controller: UIViewController, error: String) {
        let AlertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel) {
            action in AlertController.dismiss(animated: true, completion: nil)
        }
        AlertController.addAction(cancelAction)
        controller.present(AlertController, animated: true, completion: nil)
    }
    func addLocation(appDelegate:AppDelegate ,controller :UIViewController)
    {
     
        
        if appDelegate.objectId != "" {
            print("hello objectId")
            let AlertController = UIAlertController(title: "", message: "User \(appDelegate.firstName) \(appDelegate.lastName) Already Posted A Student Location. Would You Like To Overwrite Their Location?", preferredStyle: .alert)
            let willOverwriteAlert = UIAlertAction(title: "Overwrite", style: UIAlertAction.Style.default) {
                action in
            controller.performSegue(withIdentifier: "toLocation", sender: self)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                action in AlertController.dismiss(animated: true, completion: nil)
            }
            
            AlertController.addAction(willOverwriteAlert)
            AlertController.addAction(cancelAction)
            
            controller.present(AlertController, animated:true, completion: nil)
        } else {
            print("hello objectId   dfd ")
            controller.performSegue(withIdentifier: "toLocation", sender: self)
        }
    }
    
    
    class func sharedInstance() -> UdacityAPI {
        struct Singleton {
            static var sharedInstance = UdacityAPI()
        }
        return Singleton.sharedInstance
    }
}


