//
//  RondaProgramasModel.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 09-08-23.
//

import Foundation
import Firebase

class RondasProgramadas: ObservableObject{
    
    @Published var Rondas: [[Ronda]] =  []
    @Published var haveComment:[[Bool]] = []
    @Published var isRealized: [[Bool]] = []
    @Published var isOmmited: [[Bool]] = []
    @Published var comments: [[String]] = []
    @Published var photoB64: [[String]] = []
    @Published var Hora: [String] = []
    @Published var Name: [String] = []
    @Published var isRealizedRound : [Bool] = []
    @Published var Fecha: String = ""
    @Published var arrayDocumentId: [String] = []
    @Published var Duracion: [String] = []
    
    @Published var Locations:[Locations] = []
    
    var Formmater: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    private var db = Firestore.firestore()
    
    func getData(){
        print("Esto es de firebase")
        //se debe de borrar la data para poder actualizar
        deleteData()
        let collection = db.collection("RondasProgramadas")
            .whereField("isRealized", isEqualTo: false)
            .whereField("Fecha", isEqualTo: "18/05/2023")
//            .whereField("Site", isEqualTo: "Casa")
            .order(by: "Hora",descending: false)
        
        
        collection.getDocuments { snap, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let snapshot = snap {
                
                DispatchQueue.main.async {
                    for document in snapshot.documents{
                        let data = document.data()
                        self.arrayDocumentId.append(document.documentID)
                        let hora = data["Hora"] as! String
                        let name = data["Nombre"] as! String
                        let isRealizedRound = data["isRealized"] as! Bool
                        let duracion = data["Duracion"] as! String
                        self.Duracion.append(duracion)
                        //La fecha siempre sera la misma del dia, es por eso que se trae
                        self.Fecha = data["Fecha"] as! String
                        self.isRealizedRound.append(isRealizedRound)
                        self.Hora.append(hora)
                        self.Name.append(name)
                        let Rondas = data["Rondas"] as? [NSDictionary]
                        if let rondas = Rondas{
                            
                            var subRondas: [Ronda] = []
                            var subHaveComment: [Bool] = []
                            var subIsRealized: [Bool] = []
                            var subIsOmmited: [Bool] = []
                            var subComments: [String] = []
                            var subPhotoB64: [String] = []


                            for val in rondas {
                                let ronda = Ronda(latitude: val["latitude"] as! String, longuitude: val["longuitude"] as! String, name: val["name"] as! String)
                                subRondas.append(ronda)
                                subHaveComment.append(false)
                                subIsRealized.append(false)
                                subIsOmmited.append(false)
                                subComments.append("")
                                subPhotoB64.append("")
                            }
                            self.Rondas.append(subRondas)
                            self.haveComment.append(subHaveComment)
                            self.isRealized.append(subIsRealized)
                            self.isOmmited.append(subIsOmmited)
                            self.comments.append(subComments)
                            self.photoB64.append(subPhotoB64)
                            
                        }

                        print("Estas son las rondas \(self.Rondas)")
                        print("Estas son los IDS \(self.arrayDocumentId)")
                        
                    }
                }
                
            }
        }
    }
    
    func deleteData(){
        DispatchQueue.main.async {
            self.Rondas.removeAll()
            self.haveComment.removeAll()
            self.isRealized.removeAll()
            self.isOmmited.removeAll()
            self.comments.removeAll()
            self.photoB64.removeAll()
            self.Hora.removeAll()
            self.Name.removeAll()
            self.isRealizedRound.removeAll()
            self.Fecha = ""
            self.arrayDocumentId.removeAll()
            self.Duracion.removeAll()
        }

    }
    
    //para rondas terminadas
    func writeData(rondasTerminadas: RondasFinalizadasInfo){
        
        do{
            let prubeac = rondasTerminadas.dictionary
            let _ = db.collection("RondasTerminadas").addDocument(data: rondasTerminadas.dictionary)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //para cambiar el valor de es realizado.
    func finishRound(documentId: String){
        do {
            try db.collection("RondasProgramadas").document(documentId).updateData(["isRealized" : true])
        }
        catch {
          print(error)
        }
    }
    
    func createRound(_ rondaProgramada: RondaProgramadaModel) throws {
        do {
            try db.collection("RondasProgramadas").addDocument(data: rondaProgramada.dictionary)
        } catch {
            throw error
        }
    }
    
}
