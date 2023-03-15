//
//  DataControlller.swift
//  CurrentLocation
//
//  Created by Joan Muñoz on 06-05-23.
//

import Foundation
import Combine
import CoreData
import SwiftUI
import CoreLocation


struct Pin: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}


//class CoreData: ObservableObject{
//    let container = NSPersistentContainer(name: "Locations")
//    
//    init() {
//        container.loadPersistentStores { description, error in
//            if let error = error{
//                print(error.localizedDescription)
//            }
//        }
//    }
//    
//    
//    func save(context: NSManagedObjectContext){
//        do{
//            try context.save()
//            print("guardado")
//        }catch
//        {
//            print("no guardado")
//        }
//    }
//    
//    func addLocation(_ Latitude: Double, _ Longuitude: Double, context: NSManagedObjectContext){
//        let location = Location(context: context)
//        location.latitude = Latitude
//        location.longuitude = Longuitude
//        
//        save(context: context)
//    }
//    
//    
//}
