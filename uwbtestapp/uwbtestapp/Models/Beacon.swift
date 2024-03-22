//
//  Beacon.swift
//  uwbtestapp
//
//  Created by Dipannita Das on 16/08/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Beacon: Codable {
    //@DocumentID var id: String? // Assuming you have an identifier field in Firestore documents
    var id: String
    var Distance: String
    var Video: String
    var EstimoteId: String
    var Name: String
    var About: String
}

