//
//  ContentView.swift
//  uwbtestapp
//
//  Created by DJ HAYDEN on 1/14/22.
//

import SwiftUI
import EstimoteUWB
import YouTubePlayerKit

struct ContentView: View {
    @StateObject var uwb: EstimoteUWBManagerExample

    let youTubePlayer = YouTubePlayer()
    
    var body: some View {
        VStack {
            List (uwb.uwbDevices) { item in
                HStack{
                    Text(item.publicIdentifier)
                    Text("Distance: \(item.distance)")
                }
            }
            if  uwb.beacon == nil {
                VStack {
                                              
                    Image("GM_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                                        
                    Text("Keep the app open as your move around to get more information and promotion about product in your phone")
                        .font(.title2)
                        .padding()
                    
                    Text("Welcome to ASTONE").font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.accentColor)
                        .padding()
                    
                    Spacer()
                }
            }else {
                
                VStack {
                    
                    /*HStack {
                        Text(uwb.curdevice?.publicIdentifier ?? "Current device")
                        Text("Distance: \(String(format: "%.2f", uwb.curdevice?.distance ?? 0.0))")
                    }*/
                                
                    YouTubePlayerView(
                        self.youTubePlayer,
                        placeholderOverlay: {
                            ProgressView()
                        }
                    )
                    .frame(height: 400)
                    .background(Color(.systemBackground))
                    
                    Text(uwb.beacon?.EstimoteId ?? "Beacon Identifier")
                   
                    Text(uwb.beacon?.Name ?? "Name")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 2)
                                        
                    Text(uwb.beacon?.About ?? "About").padding(.bottom, 5)
                    
                    Spacer()
                        
                }.padding()
            }
        }.preferredColorScheme(.dark)
    }
    
    init() {
        let uwbInstance = EstimoteUWBManagerExample() // Create an instance
        uwbInstance.youTubePlayer = youTubePlayer // Set the YouTubePlayer instance
        _uwb = StateObject(wrappedValue: uwbInstance) // Assign to the @StateObject property
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class EstimoteUWBManagerExample: NSObject, ObservableObject {
    private var uwbManager: EstimoteUWBManager?
    var youTubePlayer: YouTubePlayer?
    
    @ObservedObject var firestoreViewModel = FireStoreManager()
    
    @Published var uwbDevices = [EstimoteUWBDevice]()
    @Published var beacon: Beacon?
    
    var currentUWBDevice: EstimoteUWBDevice?

    override init() {
        super.init()
        firestoreViewModel.getBeacons()
        setupUWB()
    }

    private func setupUWB() {
        uwbManager = EstimoteUWBManager(delegate: self,
                                        options: EstimoteUWBOptions(shouldHandleConnectivity: true,
                                                                    isCameraAssisted: true))
        uwbManager?.startScanning()
    }
}

// REQUIRED PROTOCOL
extension EstimoteUWBManagerExample: EstimoteUWBManagerDelegate {
    func didUpdatePosition(for device: EstimoteUWBDevice) {
        print("position updated for device: \(device)")
        
       // DispatchQueue.main.async {
            
            if let existingIndex = self.uwbDevices.firstIndex(where: { $0.publicIdentifier == device.publicIdentifier }) {
                // Update the existing device if found
                self.uwbDevices[existingIndex] = device
            } else {
                // Append the new device if it doesn't exist in the array
                self.uwbDevices.append(device)
            }
      //  }
                    
        if !firestoreViewModel.beacons.isEmpty {
            
            //if device not current device and distance less than 5 switch video
            if device.publicIdentifier != currentUWBDevice?.publicIdentifier && device.distance <= 3 {
                
                currentUWBDevice = device
                //print("Public identifiers are not equal")
                                
                if let foundBeacon = firestoreViewModel.beacons.first(where: { $0.EstimoteId == device.publicIdentifier }) {
                    beacon = foundBeacon
                 //   self.youTubePlayer?.source = .video(id:beacon!.Video)
                   // print("Found beacon: \(foundBeacon)")
                    
                } else {
                    // No beacon with the specified EstimoteId was found
                    //print("No beacon found for the specified EstimoteId")
                }
                
            } else {
               // print("Public identifiers are equal")
            }
        }else {
            //print("Yet to get firetore data")
        }

    }
    
    // OPTIONAL
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        print("Discovered Device: \(device.publicIdentifier) rssi: \(rssi)")
        // if shouldHandleConnectivity is set to true - then you could call manager.connect(to: device)
        // additionally you can globally call discoonect from the scope where you have inititated EstimoteUWBManager -> disconnect(from: device) or disconnect(from: publicId)
        //manager.connect(to: device)
    }
    
    // OPTIONAL
    func didConnect(to device: UWBIdentifiable) {
        print("Successfully Connected to: \(device.publicIdentifier)")
    }
    
    // OPTIONAL
    func didDisconnect(from device: UWBIdentifiable, error: Error?) {
        DispatchQueue.main.async {
            print("Disconnected from device: \(device.publicIdentifier)- error: \(String(describing: error))")
            self.uwbDevices.removeAll { uwbdevice in
                uwbdevice.publicIdentifier == device.publicIdentifier
            }
        }
    }
    
    // OPTIONAL
    func didFailToConnect(to device: UWBIdentifiable, error: Error?) {
        print("Failed to conenct to: \(device.publicIdentifier) - error: \(String(describing: error))")
    }

    // OPTIONAL PROTOCOL FOR BEACON BLE RANGING
    /*func didRange(for beacon: EstimoteBLEDevice) {
        print("beacon did range: \(beacon)")
    }*/
}


