//
//  LinkViewController.swift
//  OnTheMapApp
//
//  Created by IbrahimGamal on 4/20/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class LinkViewController: UIViewController ,UITextFieldDelegate{
    var location: String = ""
    var appDelegate: AppDelegate!
    var mediaURL: String = ""
    var point = MKPointAnnotation()
    var latitude: Double = 0.00
    var longitude: Double = 0.00
    @IBOutlet weak var linktxt: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var spinner = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
linktxt.delegate=self
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let pinAnnotationView = MKPinAnnotationView(annotation: point, reuseIdentifier: nil)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: point.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.centerCoordinate = point.coordinate
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
        self.mapView.delegate = self as? MKMapViewDelegate
        
    }
    @IBAction func submit(_ sender: Any)
    {
        spinner=showSpinner()
        spinner.hidesWhenStopped=true
    mediaURL = linktxt.text!
    
    let studentInfo = Student(dictionary: ["firstName" : appDelegate.firstName as AnyObject, "lastName": appDelegate.lastName as AnyObject, "mediaURL": mediaURL as AnyObject, "latitude": latitude as AnyObject, "longitude": longitude as AnyObject, "objectId": appDelegate.objectId as AnyObject, "uniqueKey": appDelegate.uniqueKey as AnyObject])
    
    
    if mediaURL == "" {
    UdacityAPI.sharedInstance().alertMaker(self, error: "Need To Enter Link!")
    } else {
   
    if appDelegate.objectId != "" {
        print("appDelegate.Rewrite true ")
    UdacityAPI.sharedInstance().updateStudentData(student: studentInfo!, location: location)
    { (success, result) in
    DispatchQueue.main.async{
    if success {
            self.spinner.stopAnimating()
       print("hello from VC true")
    
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is MapViewController {
                
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }

    } else {
    UdacityAPI.sharedInstance().alertMaker(self, error: "Failed To Update Location!")
    }
    
    }
        }
    }
        
        ////
        
        
        
        else {
   print("appDelegate.Rewrite false ")
        UdacityAPI.sharedInstance().postNewStudent(student: studentInfo!, location: location) {success, result in
    DispatchQueue.main.async{
    if success {
        self.spinner.stopAnimating()
    print("hello from VC false")
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is MapViewController {
                
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }

    
    }
    else {
    UdacityAPI.sharedInstance().alertMaker(self, error: "Failed To Update Location!")
    }
    }
    }
    
    }
    
}
    }


func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    linktxt.resignFirstResponder()
    
    return true
}
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
    }
   

}
