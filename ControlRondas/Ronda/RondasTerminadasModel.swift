//
//  RondasTerminadasModel.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 05-08-23.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class RondasTerminadas: ObservableObject{
    @Published var ArrayRondasFinalizadas: [RondasFinalizadasInfo] = []
    
    var Formmater: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    private var db = Firestore.firestore()
    
//    func getData(){
//        print("Esto es de firebase")
//        let collection = db.collection("RondasTerminadas")
//        collection.getDocuments { snap, error in
//            if let error = error{
//                print(error.localizedDescription)
//                return
//            }
//            if let snapshot = snap {
//                DispatchQueue.main.async {
//                    for document in snapshot.documents{
//                        if let data = document.data(), let jsonData = try? JSONSerialization.data(withJSONObject: data), let rondasFinalizadasInfo = try? JSONDecoder().decode(RondasFinalizadasInfo.self, from: jsonData) {
//                            self.ArrayRondasFinalizadas.append(rondasFinalizadasInfo)
//                        }
//                    }
//                }
//
//            }
//        }
//    }
    
    func fetchData() {
        db.collection("RondasTerminadas").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.ArrayRondasFinalizadas = documents.map { queryDocumentSnapshot -> RondasFinalizadasInfo in
                let data = queryDocumentSnapshot.data()
                let comment = data["comment"] as! [String]
                let isRealized = data["isRealized"] as! [Bool]
                let photoB64 = data["photob64"] as! [String]
                let fecha = data["fecha"] as! String
                let userRelized = data["userRealized"] as! String
                var locationsArray: [Locations] = []
                if let locationsData = data["locations"] as? [[String: Any]] {
                    // Convertir los datos del array en instancias de Locations
                    locationsArray = locationsData.compactMap { locationData -> Locations? in
                        if let latitude = locationData["latitude"] as? Double,
                           let longitude = locationData["longitude"] as? Double {
                            return Locations(latitude: latitude, longuitude: longitude)
                        } else {
                            return nil
                        }
                    }
                }
                let duracion = data["duracion"] as! String
                let isOmmited = data["ommited"] as! [Bool]
                let namePoint = data["namesPoint"] as? [String] ?? ["punto1"]
                
                return RondasFinalizadasInfo(isRealized: isRealized, comments: comment, photoB64: photoB64, fecha: fecha, userRealized: userRelized, locations: locationsArray, duracion: duracion, isOmmited: isOmmited, namePoint: namePoint)
            }
        }
    }
    
    //este se utiliza para cuando se ingresa como vigilante y solamente se quiere tener las rondas del vigilante para ver las rondas realizadas.
    func fetchDataByVigilant(_ nameVigilant: String) {
        db.collection("RondasTerminadas")
            .whereField("userRealized", isEqualTo: nameVigilant)
            .addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.ArrayRondasFinalizadas = documents.map { queryDocumentSnapshot -> RondasFinalizadasInfo in
                let data = queryDocumentSnapshot.data()
                let comment = data["comment"] as! [String]
                let isRealized = data["isRealized"] as! [Bool]
                let photoB64 = data["photob64"] as! [String]
                let fecha = data["fecha"] as! String
                let userRelized = data["userRealized"] as! String
                var locationsArray: [Locations] = []
                if let locationsData = data["locations"] as? [[String: Any]] {
                    // Convertir los datos del array en instancias de Locations
                    locationsArray = locationsData.compactMap { locationData -> Locations? in
                        if let latitude = locationData["latitude"] as? Double,
                           let longitude = locationData["longitude"] as? Double {
                            return Locations(latitude: latitude, longuitude: longitude)
                        } else {
                            return nil
                        }
                    }
                }
                let duracion = data["duracion"] as! String
                let isOmmited = data["ommited"] as! [Bool]
                let namePoint = data["namesPoint"] as? [String] ?? ["punto1"]
                
                return RondasFinalizadasInfo(isRealized: isRealized, comments: comment, photoB64: photoB64, fecha: fecha, userRealized: userRelized, locations: locationsArray, duracion: duracion, isOmmited: isOmmited, namePoint: namePoint)
            }
        }
    }
    
}


//struct RondasFinalizadasInfo1: Codable{
//    let isRealized: [Bool]
//    let comments: [String]
//    let photoB64: [String]
//    let fecha: String
//    let userRealized: String
//    let locations: [Locations]
//    let duracion: String
//    let isOmmited: [Bool]
//    var dictionary:[String:Any]{
//        return ["isRealized":isRealized,"comment":comments,"photob64":photoB64,"fecha":fecha,"userRealized":userRealized,"locations":locations.map({ location in
//            return [
//                "latitude": location.latitude,
//                "longitude": location.longuitude
//            ]
//        }),"duracion":duracion, "ommited":isOmmited]
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case isRealized
//        case comments
//        case photoB64
//        case fecha
//        case userRealized
//        case locations
//        case duracion
//        case isOmmited
//    }
//}
