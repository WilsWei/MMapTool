//
//  Directions.swift
//  MMapTool
//
//  Created by Siang on 2017/3/22.
//  Copyright © 2017年 Siang. All rights reserved.
//

import UIKit

struct Directions {
    var routes : [route]
    
    struct route {
        let legs : [leg]
    }
    
    
  //    let orglocation: (latitude: Double, longitude: Double)
    struct leg {
        let distance : (text: String, value: Double)
        let duration : (text: String, value: Double)
        let start_address : String
        let start_location :(latitude: Double, longitude: Double)
        let end_address :String
        let end_location :(latitude: Double, longitude: Double)
        let steps : [step]
    }
    
    struct step {
        let distance : (text: String, value: Double)
        let duration : (text: String, value: Double)
        let start_location :(latitude: Double, longitude: Double)
        let end_location :(latitude: Double, longitude: Double)
        let html_instructions : String
        let polyline : String
        let travel_mode : String
    }
}

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

extension Directions {
    init?(json: [String: Any]) throws {
        
        var routes = Array<Directions.route>()
        var legs = Array<Directions.leg>()
        var steps = Array<Directions.step>()
        
        
        for case let route in json["routes"] as! [[String:Any]] {
//            print(route)
            for case let leg in route["legs"] as! [[String:Any]] {
//                print(leg)
                
                guard
                    let distance = leg["distance"] as? [String:Any],
                    let distanceText = distance["text"] as? String,
                    let distanceValue = distance["value"] as? Double,
                    let duration = leg["duration"] as? [String:Any],
                    let durationText = duration["text"] as? String,
                    let durationValue = duration["value"] as? Double,
                    let start_address = leg["start_address"] as? String,
                    let start_location = leg["start_location"] as? [String:Any],
                    let start_location_latitude = start_location["lat"] as? Double,
                    let start_location_longitude = start_location["lng"] as? Double,
                    let end_address = leg["end_address"] as? String,
                    let end_location = leg["end_location"] as? [String:Any],
                    let end_location_latitude = end_location["lat"] as? Double,
                    let end_location_longitude = end_location["lng"] as? Double
                else {
                    throw SerializationError.missing("legs-data")
                }
                
                for case let stepsJson in leg["steps"] as! [[String:Any]] {
                    guard
                        let steps_distance = stepsJson["distance"] as? [String:Any],
                        let steps_distanceText = steps_distance["text"] as? String,
                        let steps_distanceValue = steps_distance["value"] as? Double,
                        let steps_duration = stepsJson["duration"] as? [String:Any],
                        let steps_durationText = steps_duration["text"] as? String,
                        let steps_durationValue = steps_duration["value"] as? Double,
                        let steps_start_location = stepsJson["start_location"] as? [String:Any],
                        let steps_start_location_latitude = steps_start_location["lat"] as? Double,
                        let steps_start_location_longitude = steps_start_location["lng"] as? Double,
                        let steps_end_location = stepsJson["end_location"] as? [String:Any],
                        let steps_end_location_latitude = steps_end_location["lat"] as? Double,
                        let steps_end_location_longitude = steps_end_location["lng"] as? Double,
                        let html_instructions = stepsJson["html_instructions"] as? String,
                        let polyline = (stepsJson["polyline"] as? [String:Any])?["points"] as? String,
                        let travel_mode = stepsJson["travel_mode"] as? String
                    else {
                        return nil
                    }
                    
                    let step = Directions.step.init(distance: (steps_distanceText, steps_distanceValue), duration: (steps_durationText, steps_durationValue), start_location: (steps_start_location_latitude, steps_start_location_longitude), end_location: (steps_end_location_latitude, steps_end_location_longitude), html_instructions: html_instructions, polyline: polyline, travel_mode: travel_mode)
                    steps.append(step)
                }
//
                let leg = Directions.leg.init(distance: (distanceText, distanceValue), duration: (durationText, durationValue), start_address: start_address, start_location: (start_location_latitude, start_location_longitude), end_address: end_address, end_location: (end_location_latitude, end_location_longitude), steps: steps)
                legs.append(leg)
            }
            
            let route = Directions.route.init(legs: legs)
            routes.append(route)
        }
        
        self.routes = routes
//
//        guard
//            let routes = json["routes"] as? [String: Any]
//        else {
//            throw SerializationError.missing("routes")
//        }
//       
//        
//        guard
//            let legs = json["legs"] as? [String: Any]
//        else {
//            throw SerializationError.missing("legs")
//        }
//        
//        guard
//            let distance = legs["distance"] as? [String:Any],
//            let distanceText = distance["text"] as? String,
//            let distanceValue = distance["value"] as? Double,
//            let duration = legs["duration"] as? [String:Any],
//            let durationText = duration["text"] as? String,
//            let durationValue = duration["value"] as? Double,
//            let start_address = legs["start_address"] as? String,
//            let start_location = legs["start_location"] as? [String:Any],
//            let start_location_latitude = start_location["lat"] as? Double,
//            let start_location_longitude = start_location["lng"] as? Double,
//            let end_address = legs["end_address"] as? String,
//            let end_location = legs["end_location"] as? [String:Any],
//            let end_location_latitude = end_location["lat"] as? Double,
//            let end_location_longitude = end_location["lng"] as? Double,
//            let stepsJson = legs["steps"] as? [String:Any]
//        else {
//            throw SerializationError.missing("legs-data")
//        }
//        
//        guard
//            let steps_distance = stepsJson["distance"] as? [String:Any],
//            let steps_distanceText = steps_distance["text"] as? String,
//            let steps_distanceValue = steps_distance["value"] as? Double,
//            let steps_duration = stepsJson["duration"] as? [String:Any],
//            let steps_durationText = steps_duration["text"] as? String,
//            let steps_durationValue = steps_duration["value"] as? Double,
//            let steps_start_location = stepsJson["start_location"] as? [String:Any],
//            let steps_start_location_latitude = steps_start_location["lat"] as? Double,
//            let steps_start_location_longitude = steps_start_location["lng"] as? Double,
//            let steps_end_location = stepsJson["end_location"] as? [String:Any],
//            let steps_end_location_latitude = steps_end_location["lat"] as? Double,
//            let steps_end_location_longitude = steps_end_location["lng"] as? Double,
//            let html_instructions = stepsJson["html_instructions"] as? String,
//            let polyline = (stepsJson["polyline"] as? [String:Any])?["points"] as? String,
//            let travel_mode = stepsJson["travel_mode"] as? String
//        else {
//             return nil
//        }
//        let steps = Directions.steps.init(distance: (steps_distanceText, steps_distanceValue), duration: (steps_durationText, steps_durationValue), start_location: (steps_start_location_latitude, steps_start_location_longitude), end_location: (steps_end_location_latitude, steps_end_location_longitude), html_instructions: html_instructions, polyline: polyline, travel_mode: travel_mode)
//
//        
//        self.legs = Directions.legs.init(distance: (distanceText, distanceValue), duration: (durationText, durationValue), start_address: start_address, start_location: (start_location_latitude, start_location_longitude), end_address: end_address, end_location: (end_location_latitude, end_location_longitude), steps: steps)
//        

        //        var meals: Set<Meal> = []
//        for string in mealsJSON {
//            guard let meal = Meal(rawValue: string) else {
//                return nil
//            }
//            
//            meals.insert(meal)
//        }
//
//        self.name = name
//        self.coordinates = (latitude, longitude)
//        self.meals = meals
    }
}

