//
//  LoginModel.swift
//  CurrentLocation
//
//  Created by Joan Muñoz on 06-05-23.
//

import Foundation
import FirebaseFirestore
//se debe de crear el login para las personas que se encuentran en firebase



class UserModel: ObservableObject{
    
    
    private var db = Firestore.firestore()
    @Published var Username = ""
    @Published var Name = ""
    @Published var isAdmin = ""
    @Published var Site: [String] = []
    @Published var photoB64 = ""
    @Published var Phone = ""
    @Published var DocumentID = ""
    
    
    
    func isInFirestore(Name:String, Password:String) async -> Int{
        let collection = try! await db.collection("Users")
            .whereField("Username", isEqualTo: "\(Name)")
            .whereField("Password", isEqualTo: "\(Password)")
            .getDocuments().count
        
        return collection
    }
    
    func getDataFromFirestore(Name:String, Password:String){
        let collection = db.collection("Users")
            .whereField("Username", isEqualTo: "\(Name)")
            .whereField("Password", isEqualTo: "\(Password)")
        
        collection.getDocuments { snap, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snap {
                
                DispatchQueue.main.async {
                    for document in snapshot.documents{
                        let data = document.data()
                        self.DocumentID = document.documentID
//                        UserDefaults.standard.setValue(self.DocumentID, forKey: "DocumentID")
                        self.Name = data["Name"] as! String
                        UserDefaults.standard.setValue(self.Name, forKey: "Name")
                        self.Username = data["Username"] as! String
                        UserDefaults.standard.setValue(self.Username, forKey: "Username")
                        self.isAdmin = data["isAdmin"] as! String
                        UserDefaults.standard.setValue(self.isAdmin, forKey: "isAdmin")
                        self.photoB64 = data["photoB64"] as? String ?? ""
                        UserDefaults.standard.setValue(self.photoB64, forKey: "photoB64Profile")
                        self.Site = data["Site"] as? [String] ?? ["Admin no site"]
                        self.Phone = data["Phone"] as? String ?? "No Number"
                        
                        UserDefaults.standard.setValue(true, forKey: "isLogged?")
                    }
                }
                
            }
        }
    }
    
    
    func editData(_ documentId: String, _ Data: Profile) -> Bool{
        do {
            try db.collection("Users").document(documentId).updateData(Data.dictionary)
            return true
        }
        catch {
          print(error)
            return false
        }
    }
    
}



struct Profile: Codable{
    var nombre: String
    var username: String
    var photoB64: String
    var phone: String
    var dictionary: [String: Any]{
        return ["Name":nombre,"Username":username,"photoB64":photoB64,"Phone":phone]
    }
}
