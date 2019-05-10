//
//  MapViewController.swift
//  OnTheMapApp
//
//  Created by IbrahimGamal on 4/20/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//
import Foundation
import UIKit
import MapKit


class MapViewController : UIViewController , MKMapViewDelegate {
    
    //Map View Info
    
    var annotations = [MKPointAnnotation]()
 
    var spinner = UIActivityIndicatorView()
    var appDelegate : AppDelegate!
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spinner=showSpinner()
        spinner.hidesWhenStopped=true
        if spinner.isAnimating == false
        {
            spinner.startAnimating()
            
        }
        loadMapView()
        
    }
    @IBAction func refresh(_ sender: Any) {
        
        if spinner.isAnimating == false
        {
            spinner.startAnimating()
            
        }
        loadMapView()
        

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        self.mapView.delegate = self
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                guard let link = URL(string: toOpen ) else {
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
        }
    }
    
    @IBAction func logoutbtn(_ sender: Any) {
        
        UdacityAPI.sharedInstance().deleteSessionID()
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addPin(_ sender: Any) {
        
        UdacityAPI.sharedInstance().addLocation(appDelegate: appDelegate,controller : self)
        
    }
    
    func loadAnnotaions() {
        self.mapView.removeAnnotations(annotations)
        annotations = [MKPointAnnotation]()
        
        for studentInfo in Student.Studentlist {
            let lat = studentInfo.lat
            let long = studentInfo.long
            //unwrap?
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentInfo.firstName
            let last = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
        
    }
    
    func loadMapView() {
        UdacityAPI.sharedInstance().allStudentsData() {(success, error) in
            if success {
                DispatchQueue.main.async {
                   
                    self.loadAnnotaions()
                     self.spinner.stopAnimating()
                }
                
            } else {
                
                self.spinner.stopAnimating()
                UdacityAPI.sharedInstance().alertMaker(self, error: "Error Getting Data!")
            }
        }
    }

}
