//
//  HomeViewController.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var mapView: MKMapView!
    
    private let pinCellIdentifier = "PinCell"
    private let locationManager = CLLocationManager()
    private let pinsService = PinsService.sharedInstance
    private var foundUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.addAnnotation(_:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
        self.rebuildAnnotations(false)
        self.showHelp()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkTokenExpiration()
        
        // we can actually check if user have location services enabled
        // and if he accepted our application to use location
        // but it isn't actually necessary - user can add pin manually
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    private func showHelp() {
        if !SettingsService.addPinHelpSeen {
            self.showErorAlertWithTitle(NSLocalizedString("Help", comment: ""), text: "Add your favorite location by simply long pressing on map")
            SettingsService.addPinHelpSeen = true
        }
    }

    private func checkTokenExpiration() {
        if let fbCredentials = SettingsService.facebookCredentials {
            if fbCredentials.isExpired() {
                SettingsService.removeSessionData()
                self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @objc
    private func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            let newCoordinates = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            self.findAddressForCoordinateAndAddPin(newCoordinates, autoSelectAnnotation: true)
        }
    }
    
    private func rebuildAnnotations(autoSelectAnnotation: Bool) {
        let annotations = self.mapView.annotations
        for annotation in annotations {
            let index = self.pinsService.pins.indexOf ({ $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude })
            if index == nil {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        for pin in self.pinsService.pins {
            if let index = self.mapView.annotations.indexOf({ $0.coordinate.latitude == pin.coordinate.latitude && $0.coordinate.longitude == pin.coordinate.longitude }) {
                let annotation = self.mapView.annotations[index]
                let annotationTitle = annotation.title ?? ""
                let annotationSubtitle = annotation.subtitle ?? ""
                if pin.title != annotationTitle ||
                    pin.formattedAddress != annotationSubtitle {
                    let updatedAnnotation = MKPointAnnotation()
                    updatedAnnotation.coordinate = annotation.coordinate
                    updatedAnnotation.title = pin.title
                    updatedAnnotation.subtitle = pin.formattedAddress
                    
                    self.mapView.removeAnnotation(annotation)
                    self.mapView.addAnnotation(updatedAnnotation)
                    self.mapView.selectAnnotation(updatedAnnotation, animated: false)
                }
            }
            else {
                let annotation = MKPointAnnotation()
                annotation.coordinate = pin.coordinate
                annotation.title = pin.title
                annotation.subtitle = pin.formattedAddress
                
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: false)
            }
        }
    }
    
    @objc
    private func addCurrentUserLocationPin() {
        let userLocation = self.mapView.userLocation
        self.mapView.deselectAnnotation(self.mapView.selectedAnnotations.first, animated: false)
        self.findAddressForCoordinateAndAddPin(userLocation.coordinate, autoSelectAnnotation: true)
    }
    
    private func findAddressForCoordinateAndAddPin(coordinate: CLLocationCoordinate2D, autoSelectAnnotation: Bool) {
        // add pin immediately to improve UX
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                print("Reverse geocoder failed with error \(error.localizedDescription)")
                return
            }
            
            var name = "Unknown Place"
            var formattedAddress = "Unknown Location"
            if let placemarks = placemarks where placemarks.count > 0 {
                let pm = placemarks[0]
                if let title = pm.name, let address = (pm.addressDictionary?["FormattedAddressLines"] as? [String])?.joinWithSeparator(", ") {
                    name = title
                    formattedAddress = address
                }
            }
            
            self.pinsService.addPinWithTitle(name, formattedAddress: formattedAddress, coordinate: coordinate)
            self.rebuildAnnotations(autoSelectAnnotation)
            self.tableView.reloadData()
        })
    }
    
    func showErorAlertWithTitle(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: NSLocalizedString("Delete", comment: "")) { (action: UITableViewRowAction, indexPath: NSIndexPath) in
            let pin = self.pinsService.pins[indexPath.row]
            self.pinsService.removePin(pin)
            self.rebuildAnnotations(false)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = UIColor.redColor()
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pin = self.pinsService.pins[indexPath.row]
        if let index = self.mapView.annotations.indexOf({ $0.coordinate.latitude == pin.coordinate.latitude && $0.coordinate.longitude == pin.coordinate.longitude }) {
            let annotation = self.mapView.annotations[index]
            self.mapView.showAnnotations([annotation], animated: true)
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pinsService.pins.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(self.pinCellIdentifier) else {
            return UITableViewCell()
        }
        let pin = self.pinsService.pins[indexPath.row]
        cell.textLabel?.text = pin.title
        cell.detailTextLabel?.text = pin.formattedAddress
        return cell
    }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation.self) {
            return nil
        }
        let annotationViewIdentifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationViewIdentifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
            annotationView?.draggable = true
            annotationView?.canShowCallout = true
            let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            deleteButton.setImage(UIImage(named: "delete"), forState: .Normal)
            annotationView?.rightCalloutAccessoryView = deleteButton
        }
        else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            if let annotation = view.annotation, title = annotation.title, subtitle = annotation.subtitle {
                if let index = self.pinsService.pins.indexOf ({ $0.title == title && $0.formattedAddress == subtitle }) {
                    let pin = self.pinsService.pins[index]
                    self.pinsService.removePin(pin)
                    self.findAddressForCoordinateAndAddPin(annotation.coordinate, autoSelectAnnotation: true)
                }
                
            }
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !self.foundUserLocation {
            
            var region = MKCoordinateRegion()
            region.center = userLocation.coordinate
            let spanValue: CLLocationDegrees = 0.005
            region.span = MKCoordinateSpan(latitudeDelta: spanValue, longitudeDelta: spanValue)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            self.foundUserLocation = true
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for view in views {
            if let annotation = view.annotation where annotation.isKindOfClass(MKUserLocation.self) {
                let button = UIButton(type: .ContactAdd)
                button.addTarget(self, action: #selector(HomeViewController.addCurrentUserLocationPin), forControlEvents: .TouchUpInside)
                view.rightCalloutAccessoryView = button
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // since we only have single remove button
        // this method perfectly suits for this case without filtering
        guard let coordinate = view.annotation?.coordinate where !view.isKindOfClass(MKUserLocation.self) else {
            return
        }
        
        if let index = self.pinsService.pins.indexOf({ $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }) {
            let pin = self.pinsService.pins[index]
            self.pinsService.removePin(pin)
            self.rebuildAnnotations(false)
            self.tableView.reloadData()
        }
    }
}

