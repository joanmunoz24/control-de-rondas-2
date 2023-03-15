//
//  RondasServer.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 07-05-23.
//

import Foundation
import CoreLocation
import SwiftUI

class RondasServer: ObservableObject{
    
    
    
    @Published var JsonWriter = []
    @Published var JSONreaderResult:[[NSArray]] = [[]]
    @Published var isRealized: [Bool] = []
    @Published var isOmmited: [Bool] = []
    @Published var haveComment: [Bool] = []
    @Published var comments: [String] = []
    @Published var photob64: [String] = []
    @Published var Header: NSArray = []
    @Published var PointsOfRound: [NSArray] = []
    @Published var Locations = []
    @Published var arrayRondas = []
    @Published var arraySend = []



    
    
    
    init() {
        loadData()
    }
    
    func loadData(){

        guard let bun = Bundle(identifier: "com.controlroll.com.ControlRondas") else { return  }
        guard let url = bun.url(forResource: "Rondas", withExtension: "json")
        else {
            print("Json file not found")
            return
        }
     
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            
            do {
//                let object = try JSONDecoder().decode([RondaModel].self, from: data)
                
                //SE DEBE DE TENER EN CONSIDERACION ESA FORMA DE TRANSFORMAR EN JSON
                let object1 = try JSONSerialization.jsonObject(with: data) as! [[NSArray]]
                self.Header = object1[0][0]
                self.PointsOfRound = object1[0][1] as! [NSArray]
                
                self.PointsOfRound.forEach { val in
                    haveComment.append(false)
                    isRealized.append(false)
                    isOmmited.append(false)
                    comments.append("")
                    photob64.append("")
                }
            } catch{print(error.localizedDescription)}
        }
        catch {print(error.localizedDescription)}

        
        
    }
    
    
    func saveJSONDataToFile(fileName: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let documentsURL = documentsURL {
            let fileURL = documentsURL.appendingPathComponent(fileName)

            print(fileURL.description)
            do {

                let json = try JSONSerialization.data(withJSONObject: JsonWriter)
                try json.write(to: fileURL, options: .atomicWrite)
            } catch {
                print(error)
            }
        }
    }
    
    func ReadJSONResult(fileName: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let documentsURL = documentsURL {
            let fileURL = documentsURL.appendingPathComponent(fileName)

            print(fileURL.description)
            do {
                let json = try String(contentsOf: fileURL)
                print(json)
            } catch {
                print(error)
            }
        }
    }
    
    
    func listDocumentDirectoryFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let url = documentsURL {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
                print("\(contents.count) files inside the document directory:")
                for file in contents {
                    print(file)
                }
            } catch {
                print("Could not retrieve contents of the document directory.")
            }
        }
    }
    
    func addToJsonWriterTest(){

        arraySend.append(Header as! [String])
        for i in PointsOfRound.indices {
            arrayRondas.append(["\(PointsOfRound[i][0])", isRealized[i], isOmmited[i], comments[i], photob64[i]])
        }
        arraySend.append(arrayRondas)
        arraySend.append(Locations)
        JsonWriter.append(arraySend)
        
        print(JsonWriter)
    }
}




//Calendar.current.dateComponents([.day,.month,.year]
