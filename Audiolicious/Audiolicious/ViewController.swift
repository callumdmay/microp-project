//
//  ViewController.swift
//  Audiolicious
//
//  Created by Callum May on 2017-11-20.
//  Copyright © 2017 Callum May. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var serviceUUIdValueLabel: UILabel!
    @IBOutlet weak var characteristicValueLabel: UILabel!
    @IBOutlet weak var getValueButton: UIButton!
    @IBOutlet weak var serviceUUIDTitleLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadStatusLabel: UILabel!
    
    var centralManager: CBCentralManager!
    var peripheral:CBPeripheral!
    var characteristic: CBCharacteristic!
    
    var uploadData: Data!
    
    let BLE_NAME = "DSAUCE1"
    let BLE_SERVICE_UUID = CBUUID(string: "02366E80-CF3A-11E1-9AB4-0002A5D5C51B")
    let BLE_CHARACTERISTIC_UUID = CBUUID(string: "340A1B80-CF4B-11E1-AC36-0002A5D5C51B")
    //let BLE_NAME = "Glucose"
    //let BLE_SERVICE_UUID = CBUUID(string: "1010")
    //let BLE_CHARACTERISTIC_UUID = CBUUID(string: "D00D")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.deviceNameLabel.text = ""
        self.characteristicValueLabel.text = ""
        self.serviceUUIdValueLabel.text = ""
        self.serviceUUIDTitleLabel.text = ""
        self.uploadStatusLabel.text = ""
        uploadButton.isHidden = true
        uploadButton.isEnabled = false
    }
    
    func uploadtoFirebase(data: Data) {
        let storageRef = Storage.storage().reference()
        let audioRef = storageRef.child("audio")
        self.uploadStatusLabel.text = "Uploading to server..."
        let uploadTask = audioRef.putData(data, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                return
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            self.uploadStatusLabel.text = "Successfully uploaded data to server"
        }
        
        uploadTask.observe(.failure) { snapshot in
            self.uploadStatusLabel.text = "Error in data upload"
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            self.connectionStatusLabel.text = "Scanning..."
        } else {
            self.connectionStatusLabel.text = "BLE not enabled"
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String : Any],
                                 rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(BLE_NAME) == true {
            self.centralManager.stopScan()
            self.connectionStatusLabel.text = "BLE Device found. Connecting..."
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            centralManager.connect(peripheral, options: nil)
        }
        
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectionStatusLabel.text = "Connected to BLE Device"
        self.getValueButton.isHidden = true
        self.getValueButton.isEnabled = false
        if let name = peripheral.name {
            self.deviceNameLabel.text = name
        }
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == BLE_SERVICE_UUID {
                self.serviceUUIDTitleLabel.text = "Service UUID:"
                self.serviceUUIdValueLabel.text = service.uuid.uuidString
                peripheral.discoverCharacteristics(
                    nil,
                    for: thisService
                )
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == BLE_CHARACTERISTIC_UUID {
                self.characteristic = thisCharacteristic
                self.peripheral.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == BLE_CHARACTERISTIC_UUID {
            if let data = characteristic.value {
                var bytes = Array(repeating: 0 as UInt8, count:data.count/MemoryLayout<UInt8>.size)
                data.copyBytes(to: &bytes, count:data.count)
            
                self.uploadData = data
                uploadButton.isHidden = false
                uploadButton.isEnabled = true
                
                var text:String = ""
                
                for byte in bytes {
                  text += "\(byte) "
                }
                self.characteristicValueLabel.text = text
            }
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.deviceNameLabel.text = ""
        self.serviceUUIdValueLabel.text = ""
        self.connectionStatusLabel.text = "Not connected"
        self.getValueButton.isHidden = false
        self.getValueButton.isEnabled = true
    }
    
    @IBAction func onGetValue(_ sender: Any) {
        if (self.centralManager.state == .poweredOn) {
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    @IBAction func onUploadPressed(_ sender: Any) {
        if let data = self.uploadData {
            uploadtoFirebase(data: data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

