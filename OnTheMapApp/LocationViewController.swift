//
//  LocationViewController.swift
//  OnTheMapApp
//
//  Created by IbrahimGamal on 4/20/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class LocationViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var locationtxt: UITextField!
    var region = MKCoordinateRegion()
    var pointAnnotation = MKPointAnnotation()
    var appDelegate: AppDelegate!
    var spinner = UIActivityIndicatorView()
    var latitude: Double = 0.00
    var longitude: Double = 0.00
    override func viewDidLoad() {
        super.viewDidLoad()
 appDelegate = UIApplication.shared.delegate as? AppDelegate
        locationtxt.delegate=self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func findLocation(_ sender: Any) {
        spinner = showSpinner()
        
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = locationtxt.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            if localSearchResponse == nil{
                UdacityAPI.sharedInstance().alertMaker(self, error: "Failed To Geocode!")
              self.spinner.stopAnimating()
                return
            }
            
             self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.locationtxt.text!
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            self.latitude = localSearchResponse!.boundingRegion.center.latitude
            self.longitude = localSearchResponse!.boundingRegion.center.longitude
             self.performSegue(withIdentifier: "toLink", sender: self)
            
    }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLink" {
            let controller = segue.destination as! LinkViewController
            // Explicitly unwrapping the link and location text fields as they should already have been checked in findLocation
            controller.location = self.locationtxt.text!
            controller.point = pointAnnotation
            controller.latitude = self.latitude
            controller.longitude = self.longitude
            self.spinner.stopAnimating()
            
        
            
        }
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            locationtxt.resignFirstResponder()
            
            return true
        }
 
}
