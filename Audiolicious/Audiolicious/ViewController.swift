//
//  ViewController.swift
//  Audiolicious
//
//  Created by Callum May on 2017-11-20.
//  Copyright © 2017 Callum May. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    var centralManager: CBCentralManager!
    var peripheral:CBPeripheral!
    
    let BEAN_NAME = "Robu"
    let BEAN_SCRATCH_UUID =
        CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let BEAN_SERVICE_UUID =
        CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            self.connectionStatusLabel.text = "Scanning..."
        } else {
            print("BLE not on")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String : Any],
                                 rssi RSSI: NSNumber) {
        self.connectionStatusLabel.text = "Found peripheral!"
    }

    @IBAction func onRefresh(_ sender: UIButton) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

