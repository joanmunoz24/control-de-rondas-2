//
//  ModelQR.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 01-08-23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ModelQR: ObservableObject{
    
    
    //En la posicion 0 va la imagen, en la posicion numero 1 va el nombre.
    @Published var arrayQRS: [[String]] = []
    @Published var arrayQRSStruct: [modelFromFirebase] = []
    
    private var db = Firestore.firestore()

    
    
    func getData(){
        print("Esto es de firebase")
        let collection = db.collection("QRS");
        collection.getDocuments { snap, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snap {
                DispatchQueue.main.async {
                    for document in snapshot.documents{
                        let documentID = document.documentID
                        let data = document.data()
                        let b64 = data["b64QR"] as! String
                        let name = data["Name"] as! String
                        let latitude = data["latitude"] as? String ?? "No lat"
                        let lon = data["longuitude"] as? String ?? "No lon"
                        let model = modelFromFirebase(b64QR: b64, Name: name, latitude: latitude, longuitude: lon, documentID: documentID)
                        let array = [b64,name,documentID,latitude,lon]
                        self.arrayQRS.append(array)
                        self.arrayQRSStruct.append(model)
                    }
                }
                
            }
        }
    }
    
    func writeData(_ Qr: modelQR, _ Site: String , _ Cliente: String){
        do{
            let ref = db.collection("QRS").addDocument(data: Qr.dictionary)
            

        }catch{
//            throw error
            print(error.localizedDescription)
        }
    }
    
    func deleteData(_ documentId: String){
        db.collection("QRS").document(documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}


struct modelQR: Codable, Hashable{
    var b64QR: String
    var Name: String
    var Site: String
    var Cliente: String
    var latitude: String
    var longuitude: String
    var dictionary:[String: Any]{
        return ["b64QR": b64QR, "Name":Name,"latitude":latitude, "longuitude":longuitude, "Site":Site, "Cliente":Cliente]
    }
}

struct modelFromFirebase: Codable, Hashable{
    var b64QR: String
    var Name: String
    var latitude: String
    var longuitude: String
    var documentID: String

}
