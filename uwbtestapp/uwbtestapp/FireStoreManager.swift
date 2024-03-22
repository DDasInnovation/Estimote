//
//  FireStoreManager.swift
//  uwbtestapp
//
//  Created by Dipannita Das on 16/08/23.
//

import Foundation
import FirebaseFirestore

class FireStoreManager: ObservableObject {
    
    @Published var beacons = [Beacon]()
    
    func getBeacons() {
        let db = Firestore.firestore()
        db.collection("iBeacons").addSnapshotListener { (querySnapshot, error) in
            
            print("firebase called")
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.beacons = documents.compactMap { (queryDocumentSnapshot) -> Beacon? in
                var data = queryDocumentSnapshot.data()
                data["id"] = queryDocumentSnapshot.documentID // Adding the Firestore document ID as 'id'
                
                do {
                    //let beacon = try data.data(as: Beacon.self)
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    // print("JSON data: \(jsonData)")
                    
                    let decoder = JSONDecoder()
                    let beacon = try decoder.decode(Beacon.self, from: jsonData)
                    print("beacon: \(beacon)")
                    
                    return beacon
                } catch {
                    print("Error decoding beacon data: \(error)")
                    return nil
                }
            }
        }
    }
    
}
