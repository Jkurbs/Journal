//
//  DataService.swift
//  Journal
//
//  Created by Kerby Jean on 4/29/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class DataService {
    
    static let shared = DataService()
    
    var RefBase: DatabaseReference {
        Database.database().reference()
    }
    
    var RefUsers: DatabaseReference {
        RefBase.child("users")
    }
    
    var RefEntries: DatabaseReference {
        RefBase.child("entries")
    }
    
    var RefStorage: StorageReference {
        Storage.storage().reference()
    }
    
    typealias completion = Result<Any?, Error>
    
    func saveEtries(name: String, speech: String, sentimen: String , date: String, completion: @escaping (completion) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data = ["name": name, "speech": speech, "sentiment": "", "date": date] as [String : Any]
        self.RefEntries.child(userId).child(name).setValue(data) { (error, data) in
            if let error = error  {
                NSLog("Error saving entries: \(error)")
                completion(.failure(error))
            } else {
                print("Save successfully")
                completion(.success(true))
            }
        }
    }
    
    func saveImg(id: String, userID: String, data: Data, _ completion: @escaping (completion) -> Void) {
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let ref = DataService.shared.RefStorage.child("entries").child(Auth.auth().currentUser!.uid).child(id)

        ref.putData(data, metadata: metadata) { _, error in
            if error != nil {
                print("Couldn't Upload Image")
            } else {
                ref.downloadURL(completion: { url, error in
                    if error != nil {
                        NSLog("Error saving image: \(String(describing: error))")
                        return
                    }
                    if url != nil {
                        completion(.success(url!.absoluteString))
                    }
                })
            }
        }
    }
    
func observeEntries(complete: @escaping (completion) -> Void) {
    RefEntries.child(Auth.auth().currentUser!.uid).observe(.value) { snapshot in
            if snapshot.exists() {
                print("SNAPSHOT: \(snapshot)")
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    guard let data = rest.data else { return }
                    let decoder = JSONDecoder()
                    do {
                        let entry = try decoder.decode(Entry.self, from: data)
                        complete(.success(entry))
                    } catch {
                        NSLog("Error fetching current user: \(error)")
                        complete(.failure(error))
                    }
                }
            }
        }
    }
}
