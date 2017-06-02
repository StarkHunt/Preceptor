//
//  MapTableViewController.swift
//  MapKitExample2
//
//  Created by Sugat Nagavkar on 31/08/16.
//  Copyright © 2016 Sugat Nagavkar. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewController: UITableViewController {
    var mapItems: [MKMapItem]!
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MapTableCell
        
        let row = indexPath.row
        let item = mapItems[row]
        
        cell.nameLabel.text = item.name
        cell.phoneLabel.text = item.phoneNumber
        
        return cell
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                                  sender: Any?) {
        
        let routeViewController = segue.destination
            as! RouteViewController
        
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
        //let indexPath = self.tableView.indexPathForSelectedRow
        
        let row = indexPath.row
        
        routeViewController.destination = mapItems![row]
    }
    
    
}
