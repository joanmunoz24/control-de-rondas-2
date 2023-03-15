//
//  ShowQRS.swift
//  ControlRondas
//
//  Created by Joan Muñoz on 01-08-23.
//

import SwiftUI

struct ShowQRS: View {
    @StateObject var modelQR = ModelQR()
    @State var isLoding = true
    
    var body: some View {
        
        if isLoding{
            ProgressView("Loading....")
                .onAppear{
                    modelQR.getData()
                    LoadData()
                }
        }else{
            List{
                if modelQR.arrayQRS.isEmpty{
                    Text("No tienes qrs creados")
                }else{
                    ForEach(modelQR.arrayQRS, id: \.self){val in
                        let b64 = val[0]
                        let name = val[1]
                        let documentID = val[2]
                        
                        HStack{
                            Image(base64String: b64)
                            VStack(alignment:.leading){
                                Text(name)
                                Text("ID: \(documentID)" )
                            }
                            
                        }
                    }.onDelete { index in
                        
                        for i in index {
                            print(self.modelQR.arrayQRS[i][2])
                            DispatchQueue.main.async {
                                let documentID = self.modelQR.arrayQRS[i][2]
                                self.modelQR.deleteData(documentID)
                                self.modelQR.arrayQRS.remove(at: i)

                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func LoadData(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.isLoding = false
        }
    }
}

struct ShowQRS_Previews: PreviewProvider {
    static var previews: some View {
        ShowQRS()
    }
}
