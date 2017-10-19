//
//  ViewController.swift
//  MMapTool
//
//  Created by Siang on 2017/3/14.
//  Copyright © 2017年 Siang. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
//import Directions

class MapViewController: UIViewController, GMSMapViewDelegate {
   
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
//    var mapView : GMSMapView!
    var origin : String!
    var destination : String!
    var placesClient: GMSPlacesClient!
    var directions : Directions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.contentView.layer.cornerRadius = 5
        self.contentView.isHidden = true
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.0685877746383, longitude: 121.497876159847, zoom: 12)
//        let rect  = CGRect()

//        self.mapView = GMSMapView.map(withFrame: self.showMapView.bounds, camera: camera)
        
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.rotateGestures = true
        self.mapView.delegate = self
        
        
        
        
//        
        placesClient = GMSPlacesClient()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: GMSMapViewDelegate
   
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition cameraPosition: GMSCameraPosition!) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("移動地圖")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //輕點一下
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // 長按
        
        self.contentView.isHidden = true
        mapView.clear()
        self.destination = nil
        self.origin = nil
        
        
        print("You Long Press tapped at \(coordinate.latitude), \(coordinate.longitude)")
        let cameraPosition = GMSCameraPosition.camera(withLatitude:coordinate.latitude, longitude: coordinate.longitude, zoom: 18)
        let myPosition = GMSCameraPosition.camera(withLatitude: mapView.myLocation!.coordinate.latitude, longitude: mapView.myLocation!.coordinate.longitude, zoom: 18)
        
        
        print("MyLocationat \(myPosition.target.latitude), \(myPosition.target.longitude)")
        print("go to at \(cameraPosition.target.latitude), \(cameraPosition.target.longitude)")
        
        getOriginAdd(cameraPosition: myPosition)
        getDestinationAdd(cameraPosition: cameraPosition)
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.clear()
        let cameraPosition = GMSCameraPosition.camera(withLatitude: mapView.myLocation!.coordinate.latitude, longitude: mapView.myLocation!.coordinate.longitude, zoom: 18)
        mapView.animate(toLocation: cameraPosition.target)
        mapView.camera = cameraPosition
        mark(for: mapView, cameraPosition: cameraPosition)
        print("MyLocationat \(cameraPosition.target.latitude), \(cameraPosition.target.longitude)")
        
        //        geocoder.reverseGeocodeCoordinate(cameraPosition.target, completionHandler: handler)
        return true
    }
    
// MARK: Call Api
    func queryNavigationPath() {
        if self.destination == nil {
            return
        }
        if self.origin == nil {
            return
        }
        
        self.directions = nil
        
        let urlstring : String = "https://maps.googleapis.com/maps/api/directions/json?origin="+self.origin.urlEncode!+"&destination="+self.destination.urlEncode!+"&mode=driving&key=AIzaSyDCn6Vd4m3ppdQ6nFQ6xVAlCPbFMWC1eYI"
        
      //        .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: urlstring)!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                
                do {

                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: AnyObject]
                    {
                        if let directions = try Directions.init(json: json) {
                            self.directions = directions
                            print(self.directions.routes[0].legs[0].distance.text)
                            print(self.directions.routes[0].legs[0].duration.text)
                            self.setDirections(directions: self.directions)
                        } else {
                            print("error in data parse")
                        }
                        
                    }
                } catch {
                    
                    print("error in JSONSerialization")
                    
                }
                
                
            }
            
        })
        task.resume()
    }
    
    
    // MARK: function
    
    func mark(for mapView: GMSMapView, cameraPosition: GMSCameraPosition) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { response, error in
            if let result = response?.firstResult() {
                //                mapView.clear()
                let marker = GMSMarker()
                let lines = result.lines! as [String]
                
                marker.position = cameraPosition.target
                marker.title = lines[0] as String
                if lines.count > 1 {
                    marker.snippet = lines[1] as String
                }
                marker.map = mapView
                
                mapView.selectedMarker = marker
            }
        }
    }
    
    func getOriginAdd(cameraPosition: GMSCameraPosition) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { response, error in
            if let result = response?.firstResult() {
                //                    mapView.clear()
                //                    let marker = GMSMarker()
                let lines = result.lines! as [String]
                self.origin = lines[0] as String;
                self.queryNavigationPath()
                //                    marker.position = cameraPosition.target
                //                    marker.title = lines[0] as String
                //                    if lines.count > 1 {
                //                        marker.snippet = lines[1] as String
            }
            //                    marker.map = mapView
            //
            //                    mapView.selectedMarker = marker
        }
    }
    
    func getDestinationAdd(cameraPosition: GMSCameraPosition) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { response, error in
            if let result = response?.firstResult() {
                //                    mapView.clear()
                //                    let marker = GMSMarker()
                let lines = result.lines! as [String]
                self.destination = lines[0] as String
                self.queryNavigationPath()
                //                    marker.position = cameraPosition.target
                //                    marker.title = lines[0] as String
                //                    if lines.count > 1 {
                //                        marker.snippet = lines[1] as String
            }
            //                    marker.map = mapView
            //
            //                    mapView.selectedMarker = marker
        }
    }
    
    func setDirections (directions: Directions) {
        let path = GMSMutablePath()
        var endPosition = GMSCameraPosition()
        
        for case let route in directions.routes {
            for case let leg in route.legs {
                for case let step in leg.steps {
                    //                     [GMSPath pathFromEncodedPath:polyLinePoints];
                    let polyLinePath = GMSPath.init(fromEncodedPath: step.polyline)
                    //                    for (int p=0; p<polyLinePath.count; p++) {
                    //                        [path addCoordinate:[polyLinePath coordinateAtIndex:p]];
                    //                    }
                    //                    for int i = 0; i < polyLinePath.count(); i++ {
                    let count : UInt = (polyLinePath?.count())!
                    for i in 0 ..< UInt(count) {
                        path.add((polyLinePath?.coordinate(at: i))!)
                    }
                    //
                }
                DispatchQueue.main.async {
                    
                    endPosition = GMSCameraPosition.camera(withLatitude:leg.end_location.latitude, longitude: leg.end_location.longitude, zoom: 13)
                    self.distanceLabel.text = String.init(format: "距離：%@", leg.distance.text)
                    self.durationLabel.text = String.init(format: "時間：%@", leg.duration.text)
                    //                var disValue = Int(leg.distance.value)
                    //                self.costLabel.text = calculationCost(leg.distance.value)
                    self.costLabel.text = {
                        () -> String in
                        var distance = leg.distance.value
                        var cost = 70
                        if distance > 1250 {
                            distance = distance - 1250
                            var count = Int(distance / 200)
                            let i = distance.truncatingRemainder(dividingBy: 200)
                            if  i != 0 {
                                count = count + 1
                            }
                            cost = cost + (5*count)
                        }
                        return String.init(format: "費用：%d 元", Int(cost))
                    }()
                    self.contentView.isHidden = false
                }
            }
            
        }
        
        mark(for: mapView, cameraPosition: endPosition)
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeColor = UIColor.blue
        rectangle.strokeWidth = 5.0
        
        //        let shapeLayer = CAShapeLayer()
        //        shapeLayer.path = rectangle.reversing().cgPath
        //        shapeLayer.strokeColor = UIColor.green.cgColor
        //        shapeLayer.lineWidth = 4.0
        //        shapeLayer.fillColor = UIColor.clear.cgColor
        //        shapeLayer.lineJoin = kCALineJoinRound
        //        shapeLayer.lineCap = kCALineCapRound
        //        shapeLayer.cornerRadius = 5
        rectangle.map = mapView

        
    }
    
    func calculationCost(distance: Double) -> String {
//        計程運價：起程1.25公里70元，續程每200公尺5元（日間）。 (2)延滯計時運價：車速每小時5公里以下，累計每1分鐘20秒5元（日間）
//        夜間加成運價：自夜間11時起至翌晨6時止（遇跨夜間加成時段之情形，統一以「上車時間」為準），每趟次依日間運價加收20元（即起程運價1.25公里90元，續程及延滯計時運價與日間相同）
        var distance = distance
        var cost = 70
        if distance > 1250 {
            distance = distance - 1250
            var count = Int(distance / 200)
            let i = distance.truncatingRemainder(dividingBy: 200)
            if  i != 0 {
                count = count + 1
            }
            cost = cost + (5*count)
        }
        return String.init(format: "費用：%d 元", Int(cost))
    }
}



extension String {
    // url encode
    var urlEncode:String? {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!*'\\\\\"();:@&=+$,/?%#[]% ").inverted)
    }
    // url decode
    var urlDecode :String? {
        return self.removingPercentEncoding
    }
}
