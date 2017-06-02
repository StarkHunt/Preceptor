//
//  RouteViewController.swift
//  MapKitExample2
//
//  Created by Sugat Nagavkar on 31/08/16.
//  Copyright © 2016 Sugat Nagavkar. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class RouteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var routeTextView: UITextView!
    @IBOutlet weak var routeView: UIView!
    @IBOutlet weak var routeMap: MKMapView!
    var locationManager = CLLocationManager()
    
    var destination: MKMapItem?
    
    override func viewDidLoad() {
        
        
        routeMap.delegate = self
        self.getDirections()
        routeTextView.text = ""
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.routeMap.showsUserLocation = true
        
//        let newLocation = CLLocationCoordinate2D(latitude: 40.730991, longitude: -74.041234)
//        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = newLocation
//        annotation.title = "Test"
//        annotation.subtitle = "Lets Run It"
//        routeMap.addAnnotation(annotation)

    }
    
    func getDirections(){
        
        let latConvert = CLLocationDegrees(LocationDetails.latitude)
        let longConvert = CLLocationDegrees(LocationDetails.longitude)
        let sourceLocation = CLLocationCoordinate2D(latitude: latConvert!, longitude: longConvert!)
        
        let place = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: place)
            //MKMapItem.forCurrentLocation()
        request.destination = destination!
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            
            if let error = error{
                print(error.localizedDescription)
                self.routeTextView.text = "\(error.localizedDescription)"
                
            }else {
                self.showRoute(response!)
                let distance = response?.routes.first?.distance
                let time = response?.routes.first?.expectedTravelTime
                print("Distance : \(distance)")
                print("Time : \(time)")
            }
            
        }
    }
    
    func showRoute(_ response: MKDirectionsResponse) {
        
        for route in response.routes as [MKRoute] {
            
            routeMap.add(route.polyline,
                                level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print("Route instructions: \(step.instructions)")
                self.routeTextView.text! += "\(step.instructions)\n"
                
            }
        }
        let latConvert = CLLocationDegrees(LocationDetails.latitude)
        let longConvert = CLLocationDegrees(LocationDetails.longitude)
        let sourceLocation = CLLocationCoordinate2D(latitude: latConvert!, longitude: longConvert!)
        
        //let userLocation = routeMap.userLocation
        let region = MKCoordinateRegionMakeWithDistance(
            sourceLocation, 2000, 2000)
        
        routeMap.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    @IBAction func directionFromCurrent(_ sender: Any) {
        
        routeTextView.text = ""
        
        let latConvert = CLLocationDegrees(routeMap.userLocation.coordinate.latitude)
        let longConvert = CLLocationDegrees(routeMap.userLocation.coordinate.longitude)
        let sourceLocation = CLLocationCoordinate2D(latitude: latConvert, longitude: longConvert)
        
        let place = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: place)
        //MKMapItem.forCurrentLocation()
        request.destination = destination!
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            
            if let error = error{
                print(error.localizedDescription)
                self.routeTextView.text = "\(error.localizedDescription)"
                
            }else {
                self.showRouteNew(response!)
                let distance = response?.routes.first?.distance
                let time = response?.routes.first?.expectedTravelTime
                print("Distance : \(distance)")
                print("Time : \(time)")
            }
            
        }

    }
    
    func showRouteNew(_ response: MKDirectionsResponse) {
        
        for route in response.routes as [MKRoute] {
            
            routeMap.add(route.polyline,
                         level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print("Route instructions: \(step.instructions)")
                self.routeTextView.text! += "\(step.instructions)\n"
                
            }
        }
//        let latConvert = CLLocationDegrees(routeMap.userLocation.coordinate.latitude)
//        let longConvert = CLLocationDegrees(routeMap.userLocation.coordinate.longitude)
//        let sourceLocation = CLLocationCoordinate2D(latitude: latConvert, longitude: longConvert)
        
        let userLocation = routeMap.userLocation
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.coordinate, 2000, 2000)
        
        routeMap.setRegion(region, animated: true)
    }
    
    
    
        func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
            let location = locations[0]
            
            
    
    
        }

    
    
    
}
