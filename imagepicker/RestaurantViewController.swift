//
//  RestaurantViewController.swift
//  imagepicker
//
//  Created by Sugat Nagavkar on 05/04/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RestaurantViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //var mapItems: [MKMapItem]!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var locationManager : CLLocationManager?
    var getDataFromNeaby = String()
    @IBOutlet weak var customMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        var coordinate = CLLocationCoordinate2D()
        
        let latitude = LocationDetails.latitude
        coordinate.latitude = CLLocationDegrees(latitude)!
        let longitude = LocationDetails.longitude
        coordinate.longitude = CLLocationDegrees(longitude)!
        
        
        let center = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        customMapView.setRegion(center, animated: true)
        
        performSearch()
 
        
        
        // Do any additional setup after loading the view.
    }
    
    func performSearch(){
        
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        let smallCase = getDataFromNeaby.lowercased()
        request.naturalLanguageQuery = smallCase
        request.region = customMapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }else if (response?.mapItems.count == 0){
                print("No matching items found")
            }else{
                print("Matches found")
                
                for item in response?.mapItems as [MKMapItem]! {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    
                    self.matchingItems.append(item as MKMapItem)
                    print("Matching items = \(self.matchingItems.count)")
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.customMapView.addAnnotation(annotation)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! MapTableViewController
        
        destinationVC.mapItems = self.matchingItems
        
    }
    
    

}
