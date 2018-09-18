//
//  ViewController.swift
//  ShipWell
//
//  Created by Matthew Foster on 17/9/18.
//  Copyright © 2018 MatthewFoster. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import MapKit
import UserNotifications


class ViewController: UIViewController,URLSessionDelegate,URLSessionDataDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    class User {
       
        private var contactName: String?
        private var primaryEmail: String?
        private var primaryPhone: String?
        
        func setUserDetails(name: String, email: String, phone: String){
            
            contactName = name
            primaryEmail = email
            primaryPhone = phone
        
        }
        
        func getContactName() -> String {
            
            return contactName ?? "N/A"
        }
        
        func getPrimaryEmail() -> String {
            
            return primaryEmail ?? "N/A"
        }
        
        func getPrimaryPhone() -> String {
            
            return primaryPhone ?? "N/A"
        }
        
    }
    
    
    func getApiData(url: String, token: String){
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        let URL = NSURL(string: url)
        var request = URLRequest(url: URL! as URL)
        
        request.httpMethod = "GET"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if (error == nil) {
                
                do{
                    let userData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
             
                    let companyInfo = userData["company"] as! NSDictionary
                
                let noData = "N/A"
    self.user.setUserDetails(name: companyInfo["name"] as? String ?? noData, email: companyInfo["primary_email"] as? String ?? noData, phone: companyInfo["primary_phone_number"] as? String ?? noData)
                
                
                 DispatchQueue.main.async {
                
                var detailString = "Name: " + self.user.getContactName() + "\n"
                detailString += "Email: " + self.user.getPrimaryEmail() + "\n"
                    detailString += "Phone: " + self.user.getPrimaryPhone() + "\n"
                
                self.details.text = detailString
                
                }
            }catch{
                
                print("No data.")
                
                }
            }
            else {
                
                
                 print("URL Session Task Failed: %@", error!.localizedDescription);
                
            }
       }
       task.resume()
    }
    
    let user = User()
    var pingTimer: Timer!
    var locationManager: CLLocationManager!
    var tableView = UITableView()
    var locations: [Location] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let zoomingMap = MKMapView()
    
    let latitudeLabel = UILabel()
    let longitudeLabel = UILabel()
    
    
    var closeButton: UIButton = {
        let cb = UIButton()
        
        cb.setTitle("Close", for: .normal)
        cb.addTarget(self, action: #selector(closeMap), for: .touchUpInside)
        cb.backgroundColor = UIColor(red:0.04, green:0.63, blue:0.86, alpha:1.0)
        cb.layer.cornerRadius = 5
        
        return cb
        
    }()
    
    var mapInfo: UIView = {
        let mv = UIView()
        
        mv.frame = CGRect(x: -1, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width + 2, height: 70)
        mv.backgroundColor = .white
        mv.layer.borderColor = UIColor.gray.cgColor
        mv.layer.borderWidth = 1
        
      return mv
    }()
    
    var userInfo: UIView = {
        let mv = UIView()
        
        mv.frame = CGRect(x: 2, y: 8, width: UIScreen.main.bounds.size.width - 2, height: 90)
        mv.backgroundColor = .white
        
        return mv
    }()
    
    var details: UITextView = {
        let dt = UITextView()
        
        dt.isScrollEnabled = false
        dt.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 0.0))
        dt.textColor = UIColor(red:0.35, green:0.35, blue:0.36, alpha:1.0)
        return dt
    }()
    
    
    var initialLocation = Bool()
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if initialLocation {
        saveLocation()
            initialLocation = false
        }
        
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLocation = true
        
        view.addSubview(userInfo)
        
        details.frame = userInfo.frame
        
        userInfo.addSubview(details)
        
        tableView.register(UINib(nibName: "locationCell", bundle: nil), forCellReuseIdentifier: "locationCell")
       
        getApiData(url: "https://dev-api.shipwell.com/v2/auth/me/", token: "4c4547fe6ad68c57cbac0a8cfbfec35b")
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 100)
        
        view.addSubview(tableView)
        
        zoomingMap.frame = view.frame
        view.addSubview(zoomingMap)
        zoomingMap.isHidden = true
        zoomingMap.delegate = self
        
        latitudeLabel.frame = CGRect(x: 10, y: 15, width: mapInfo.frame.width - 100, height: 20)
        longitudeLabel.frame = CGRect(x: 10, y: 36, width: mapInfo.frame.width - 100, height: 20)
        latitudeLabel.textColor = UIColor(red:0.35, green:0.35, blue:0.36, alpha:1.0)
        longitudeLabel.textColor = UIColor(red:0.35, green:0.35, blue:0.36, alpha:1.0)
        
        closeButton.frame = CGRect(x: mapInfo.frame.width - 90, y: 20, width: 80, height: 30)
        
        mapInfo.addSubview(latitudeLabel)
        mapInfo.addSubview(longitudeLabel)
        mapInfo.addSubview(closeButton)
 
        view.addSubview(mapInfo)
        
        if(CLLocationManager.locationServicesEnabled()){
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            pingTimer =  Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(saveLocation), userInfo: nil, repeats: true)
        }
       
}
   
    
    @objc func saveLocation(){
        
        let date = Date()
        
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let entry = Location(context: context)
        entry.latitude = Float((locationManager.location?.coordinate.latitude)!)
        entry.longitude = Float((locationManager.location?.coordinate.longitude)!)
        entry.date = date
        
       
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        getData()
        tableView.reloadData()
        
        let content = UNMutableNotificationContent()
        content.title = "Location Saved"
        content.body = "Lat: " + String((locationManager.location?.coordinate.latitude)!) + "\n"
        content.body += "Long: " + String((locationManager.location?.coordinate.longitude)!)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "googleMapsView") as! googleMapsView
        
        let location = locations[indexPath.row]
        nextViewController.lat = String(location.latitude)
        nextViewController.long = String(location.longitude)
        
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
       let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! locationCell
        
        let location = locations[indexPath.row]
        
        let dateformatter = DateFormatter()
            
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
            
        cell.date.text = dateformatter.string(from: location.date ?? Date())
        cell.latitude.text = String(location.latitude)
        cell.longitude.text = String(location.longitude)
        
        cell.LocationView.hideAttributedView()
        
        cell.LocationView.delegate = self
        
        cell.LocationView.tag = indexPath.row
        
        let dropPin = MKPointAnnotation()
       
        dropPin.coordinate.latitude = CLLocationDegrees(location.latitude)
        dropPin.coordinate.longitude = CLLocationDegrees(location.longitude)
        
        cell.LocationView.removeAnnotations(cell.LocationView.annotations)
        
        cell.LocationView.addAnnotation(dropPin)
        
        let center = CLLocationCoordinate2D(latitude: dropPin.coordinate.latitude, longitude: dropPin.coordinate.longitude)
        var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        region.center = dropPin.coordinate
        
        cell.LocationView.setRegion(region, animated: false)
        
        let tapMap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMap(_:)))
        
        cell.LocationView.addGestureRecognizer(tapMap)
        
        return cell
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.layer.removeAllAnimations()
    }
    
 
    
    @objc func zoomMap(_ gesture: UIGestureRecognizer){
        
        var mapTag = Int()
        
        if let mapview = gesture.view as? MKMapView {
            mapTag = mapview.tag
        }
        
        zoomingMap.removeAnnotations(zoomingMap.annotations)
        let location = locations[mapTag]
        let dropPin = MKPointAnnotation()
        
        dropPin.coordinate.latitude = CLLocationDegrees(location.latitude)
        dropPin.coordinate.longitude = CLLocationDegrees(location.longitude)
        zoomingMap.addAnnotation(dropPin)
        
        var region = MKCoordinateRegion(center: dropPin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        region.center = dropPin.coordinate
        
        zoomingMap.isHidden = false
        zoomingMap.alpha = 1.0
        
        
        latitudeLabel.text = "Lat: " + String(location.latitude)
        longitudeLabel.text = "Long: " + String(location.longitude)
        
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred()
        
        zoomingMap.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        
        
        UIView.animate(withDuration:1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 6.0, options: .allowUserInteraction,
                       animations: ({
                        
                       self.zoomingMap.transform = .identity
                        
        }), completion: {(isCompleted) in
            if isCompleted {
                self.zoomingMap.setRegion(region, animated:true)
            }})
        
        
        
        
        UIView.animate(withDuration:0.4, delay: 1.0, options: .allowUserInteraction,
                      animations: {
            
            self.mapInfo.frame = CGRect(x:-1, y: UIScreen.main.bounds.size.height - 70, width: UIScreen.main.bounds.size.width + 2, height: 70)
            
                    }, completion: nil )
        
        
    }
    
    @objc func closeMap(_ sender: UIButton){
        
        
        UIView.animate(withDuration:0.4, delay: 0.0, options: .allowUserInteraction,
                       animations: {
                        
                        self.mapInfo.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 70)
                        
        }, completion: nil )
        
        
        UIView.animate(withDuration:0.3, delay: 0.4, options: .allowUserInteraction,
                       animations: {
                        self.zoomingMap.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        self.zoomingMap.alpha = 0.0
                        
        }, completion: nil )
        
    }
    
    func getData() {
        
        do {
            locations = try context.fetch(Location.fetchRequest())
            locations.reverse()
        }
        catch {
            print("Fetching Failed")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = locations[indexPath.row]
            context.delete(location)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                locations = try context.fetch(Location.fetchRequest())
            }
            catch {
                print("Fetching Failed")
            }
        }
        tableView.reloadData()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKMarkerAnnotationView
        
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        pinView?.markerTintColor = UIColor(red:0.04, green:0.63, blue:0.86, alpha:1.0)
        
        pinView?.isUserInteractionEnabled = false
        
        return pinView
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension MKMapView {
    var attributedView: UIView? {
        for subview in subviews {
            if String(describing: type(of: subview)).contains("Label") {
                return subview
            }
        }
        return nil
    }
    
    func hideAttributedView() {
        guard let attributedView = attributedView else {
            return
        }
        attributedView.isHidden = true
    }
}

