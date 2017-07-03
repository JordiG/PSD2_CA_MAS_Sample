//
//  APIResults.swift
//  MAS Sandbox
//
//  Created by JORDI GASCON on 04/04/2017.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import Foundation
import MASFoundation
import MASUI

func callCAPSD2API (api2call:String, params:[String]) -> String {
    var texto ? ""
    if let apistring = api2call {
       
        ViewController.txtAPIResponse.text = "Initiating the GET HTTP Request\n"
        txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/customer/summary/v1] for Customer Full Statement API \n"
        
        // Customer Full Statement thru the MAG SDK
        
        MAS.getFrom("/customer/summary/v1", withParameters: nil, andHeaders: nil, completion: { (response, error) in
            
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
            }
            //Update the MAS Log TextView with the latest device registration info
            if self.txtMASLog.text == nil {
                self.txtMASLog.text = ""
            }
            self.txtMASLog.text = self.txtMASLog.text + "MAG has been successfully started\n"
            self.txtMASLog.text = self.txtMASLog.text + "MAG Device Stack information:\n"
            self.txtMASLog.text = self.txtMASLog.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
            self.txtMASLog.text = self.txtMASLog.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
            self.deviceStatus()
            self.userStatus()
            if self.txtAPIResponse.text == nil {
                self.txtAPIResponse.text = ""
            }
            self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
            //Print out the response (JSON from the Gateway)
            // print("API response: \(response?.debugDescription)")
            //Add the response to the textView
            
            if ((response?.debugDescription) != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + (response?.debugDescription)!
            }
            print("Response \(String(describing: response?["MASResponseInfoBodyInfoKey"]))")
            
            let cabecera = response?[MASResponseInfoHeaderInfoKey] as! NSDictionary
            print("Cabecera:....")
            // print(myDictionary["First"])
            
            // iterate over all keys
            for (key, value) in cabecera {
                print("Key: \(key) - Value: \(value)")
            }
            let cuerpo = response?[MASResponseInfoBodyInfoKey] as! NSDictionary
            //
            print("Cuerpo:....")
            for (key, value) in cuerpo {
                print("Key: \(key) - Value: \(value)")
            }
            
            
        })
    
    }
}
