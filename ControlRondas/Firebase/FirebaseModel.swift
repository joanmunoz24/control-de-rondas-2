//
//  FirebaseModel.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 29-05-23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift




//Esta es la clase para traer las rondas
class ViewModel: ObservableObject{
    @Published var Data: [String] = []
    @Published var Rondas: [Ronda] =  []
    @Published var haveComment:[Bool] = []
    @Published var isRealized: [Bool] = []
    @Published var isOmmited: [Bool] = []
    @Published var comments: [String] = []
    @Published var photoB64:[String] = []
    
    @Published var Locations:[Locations] = []
    
    var Formmater: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    private var db = Firestore.firestore()
    
    func getData(){
        print("Esto es de firebase")
        let collection = db.collection("RondasProgramadas")
            .whereField("isRealized", isEqualTo: false)
            .whereField("Fecha", isEqualTo: "18/05/2023")
        
        
        collection.getDocuments { snap, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snap {
                
                DispatchQueue.main.async {
                    for document in snapshot.documents{
                        let data = document.data()
                        let info = data["Site"] as? [String]
                        let Rondas = data["Rondas"] as? [NSDictionary]
                        if let rondas = Rondas, let Data = info{
                            self.Data = Data
                            self.Rondas = rondas.map{d in
                                self.haveComment.append(false)
                                self.isRealized.append(false)
                                self.isOmmited.append(false)
                                self.comments.append("")
                                self.photoB64.append("")
                                return Ronda(latitude: d["latitude"] as! String, longuitude: d["longuitude"] as! String, name: d["name"] as! String)
                            }
                        }

                        print("Estas son las rondas \(self.Rondas)")
                        
                    }
                }
                
            }
        }
    }
    
    func writeData(rondasTerminadas: RondasFinalizadasInfo){
        
        do{
            let prubeac = rondasTerminadas.dictionary
            let _ = db.collection("RondasTerminadas").addDocument(data: rondasTerminadas.dictionary)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
}




struct Info: Codable {
    let data: [String]
    let rondas: [Ronda]
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
        case rondas = "Rondas"
    }
}

struct Ronda: Codable, Hashable{
    let latitude: String
    let longuitude: String
    let name: String
}

struct Locations: Identifiable,Codable{
    let id = UUID()
    var latitude: Double
    var longuitude: Double
}

struct RondasFinalizadasInfo: Codable{
    let isRealized: [Bool]
    let comments: [String]
    let photoB64: [String]
    let fecha: String
    let userRealized: String
    var locations: [Locations]
    let duracion: String
    let isOmmited: [Bool]
    let namePoint: [String]
    var dictionary:[String:Any]{
        return ["isRealized":isRealized,"comment":comments,"photob64":photoB64,"fecha":fecha,"userRealized":userRealized,"locations":locations.map({ location in
            return [
                "latitude": location.latitude,
                "longitude": location.longuitude
            ]
        }),"duracion":duracion, "ommited":isOmmited, "namesPoint": namePoint]
    }
    
    enum CodingKeys: String, CodingKey {
        case isRealized
        case comments
        case photoB64
        case fecha
        case userRealized
        case locations
        case duracion
        case isOmmited
        case namePoint
    }
}



