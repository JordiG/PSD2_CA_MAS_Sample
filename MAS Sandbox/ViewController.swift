//
//  ViewController.swift
//  Sprint Password
//
//  Created by Alan Cota on 3/6/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI

class ViewController: UIViewController {

    @IBOutlet weak var btnStartMAS: UIButton!
    @IBOutlet weak var txtMASLog: UITextView!
    @IBOutlet weak var btnAPICall: UIButton!
    @IBOutlet weak var txtAPIResponse: UITextView!
    @IBOutlet weak var btnClearLog: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnDeregister: UIButton!
    @IBOutlet weak var imgDeviceStatus: UIImageView!
    @IBOutlet weak var imgUserStatus: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Add borders to the textViews for better presentation
        //
        self.txtMASLog.layer.borderWidth=1
        self.txtMASLog.layer.borderColor=UIColor.black.cgColor
        
        self.txtAPIResponse.layer.borderWidth=1
        self.txtAPIResponse.layer.borderColor=UIColor.black.cgColor
        
        //
        // Clear the textviews
        //
        txtMASLog.text=nil
        txtAPIResponse.text=nil
        
        //
        // If the device is registered change the image status
        //
        deviceStatus()
        userStatus()
    }


    //
    // MAS Start Stack
    //
    @IBAction func btnStartMASTapped(_ sender: Any) {
        
        //
        //Define the Grant Flow as Client Credentials
        //
        MAS.setGrantFlow(MASGrantFlow.password)
        txtMASLog.text = "Grant flow set: Password\n"
        //
        // MAS Start with default configruation
        //
        txtMASLog.text = txtMASLog.text + "Starting the MAG SDK\n"
        MAS.start(withDefaultConfiguration: true) { (completed: Bool, error: Error?) in
            
            //
            // Handle the error
            //
            if (error != nil) {
                self.txtMASLog.text = self.txtMASLog.text + "MAG Start error: \(error.debugDescription)\n"
            }
            
            //
            // Handle the success
            //
            
            if (completed) {
                self.txtMASLog.text = self.txtMASLog.text + "MAG has been successfully started\n"
                self.txtMASLog.text = self.txtMASLog.text + "MAG Device Stack information:\n"
                self.txtMASLog.text = self.txtMASLog.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
                self.txtMASLog.text = self.txtMASLog.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
                self.deviceStatus()
                self.userStatus()
            }
            
            
            
        }
        
    }
    
    //
    // HTTP GET Through the SDK
    //
    @IBAction func btnAPICallTapped(_ sender: Any) {
        
        txtAPIResponse.text = "Initiating the GET HTTP Request\n"
        txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/customer/data/v1]\n"
    // GET customer/accounts/v1
        //SDK has been started successfully
        
        
      //  MAS.getFrom("/customer/data/v1", withParameters: nil, andHeaders: nil, completion: { (response, error) in
    //       MAS.getFrom("/protected/resource/products", withParameters: ["operation":"listProducts"], andHeaders: nil, completion: { (response, error) in
         MAS.getFrom("/v1/Weather", withParameters: nil, andHeaders: nil, completion: { (response, error) in

            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                
            }
            
            //Update the MAS Log TextView with the latest device registration info
            self.txtMASLog.text = self.txtMASLog.text + "MAG has been successfully started\n"
            self.txtMASLog.text = self.txtMASLog.text + "MAG Device Stack information:\n"
            self.txtMASLog.text = self.txtMASLog.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
            self.txtMASLog.text = self.txtMASLog.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
            self.deviceStatus()
            self.userStatus()
            
            self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
            //Print out the response (JSON from the Gateway)
            print("Available products response: \(response?.debugDescription)")
            //Add the response to the textView
            
            if ((response?.debugDescription) != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + (response?.debugDescription)!
            }
            
        })
        
    }
    
    
    //
    // Clear the logs
    //
    @IBAction func btnClearLogTapped(_ sender: Any) {
        
         txtMASLog.text = nil
         txtAPIResponse.text = nil
        
    }
    
    //
    // Logout the user
    //
    @IBAction func btnLogoutTapped(_ sender: Any) {
        
        txtMASLog.text = txtMASLog.text + "\n------\nPerforming the user logout\n"
        
        if ((MASUser.current()) != nil) {
        MASUser.current().logout { (completed: Bool, error: Error?) in
            //
            // Handle the error
            //
            if (error != nil) {
                self.txtMASLog.text = self.txtMASLog.text + "User Logout error: \(error.debugDescription)\n"
            }
            
            //Update the MAS Log TextView with the latest device registration info
            self.txtMASLog.text = self.txtMASLog.text + "The user has been successfully logged out\n"
            self.txtMASLog.text = self.txtMASLog.text + "MAG Device Stack information:\n"
            self.txtMASLog.text = self.txtMASLog.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
            self.txtMASLog.text = self.txtMASLog.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
            
            self.deviceStatus()
            
            self.userStatus()
            self.imgUserStatus.image = #imageLiteral(resourceName: "loggedout")
            
            }
        }
        else {
            
            txtMASLog.text = txtMASLog.text + "\n------\nUser was not logged in\n"
        }
    }
    
    //
    // De-register the device
    //
    @IBAction func btnDeregisterTapped(_ sender: Any) {
        
        txtMASLog.text = txtMASLog.text + "\n------\nStarting the Device De-registration process\n"
        if MASDevice.current() != nil {
        MASDevice.current().deregister { (completed: Bool, error: Error?) in
            
            //
            // Handle the error
            //
            if (error != nil) {
                self.txtMASLog.text = self.txtMASLog.text + "Device de-registration error: \(error.debugDescription)\n"
            }
            
            self.txtMASLog.text = self.txtMASLog.text + "\n---------------\n\nThe Device has been successfully de-registered\n"
            self.txtMASLog.text = self.txtMASLog.text + "MAG Device Stack information:\n"
            self.txtMASLog.text = self.txtMASLog.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
            self.txtMASLog.text = self.txtMASLog.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
            self.imgDeviceStatus.image = #imageLiteral(resourceName: "unregistered")
            
        }
        } else {
            txtMASLog.text = txtMASLog.text + "\n------\nDevice was not registered\n"
        }
        
    }
    
    //
    // Function to check the device status and update the image
    //
    func deviceStatus() {
        
        if ((MASDevice.current()) != nil) {
            
            if (MASDevice.current().isRegistered) {
                imgDeviceStatus.image = #imageLiteral(resourceName: "registered")
            } else {
                imgDeviceStatus.image = #imageLiteral(resourceName: "unregistered")
            }
        
        }
    }
    
    //
    // Function to update the user status
    //
    func userStatus() {
        
        if ((MASUser.current()) != nil) {
            if (MASUser.current().isAuthenticated) {
                
                imgUserStatus.image = #imageLiteral(resourceName: "logged")
                self.txtMASLog.text = self.txtMASLog.text + "Is the User authenticated? : \(MASUser.current().isAuthenticated)\n"
                
            } else {
                
                imgUserStatus.image = #imageLiteral(resourceName: "loggedout")
                self.txtMASLog.text = self.txtMASLog.text + "Is the User authenticated? : false\n"
                
            }
        }
        
    }
    
}
