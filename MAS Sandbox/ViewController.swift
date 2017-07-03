//
//  ViewController.swift
//  Sprint Password
//
//  Created by Jordi Gascon 3/21/17. Based on a sample from Alan Cota on 3/6/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI



class ViewController: UIViewController {

    @IBOutlet weak var btnStartMAS: UIButton!

    @IBOutlet weak var btnAPICall: UIButton!
    @IBOutlet weak var txtAPIResponse: UITextView!
    @IBOutlet weak var btnClearLog: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnDeregister: UIButton!
    @IBOutlet weak var imgDeviceStatus: UIImageView!
    @IBOutlet weak var imgUserStatus: UIImageView!
    
    @IBOutlet weak var txtFundstoCheck: UITextField!
    

    
    // Hacer que el teclado se oculte si se pulsa return sin introducir nada o se hace tap fuera de el teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtFundstoCheck.resignFirstResponder()
         // texto.resignFirstResponder() // cambiar texto por el nombre que se le haya dado a campo field
        return true
     }
    override func viewDidAppear(_ animated: Bool) {
        
        // deberia ser boton Logout si esta login y Login si esta logout
        if let atoken = MASUser.current()?.accessToken {
            //    self.txtAPIResponse.text = self.txtAPIResponse.text + "Access Token? : \(atoken)\n"
            print("token: \(atoken)")
            // logmessage = logmessage + ("using token: \(atoken) \n")
            
            btnLogout.titleLabel?.text = "Logout"
            
        } else {
            btnLogout.titleLabel?.text = "Login"
            print("no token")
            // logmessage = logmessage + ("No token. Log in first \n")
            
        }


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        let timeString = "Log started at: \(dateFormatter.string(from: Date() as Date))" + "\n"
        
        SharingLog.sharedInstance.logMessage = timeString
        
        let logtxtmessage: String = SharingLog.sharedInstance.logMessage
        self.txtAPIResponse.text = logtxtmessage
        //
        // Add borders to the textViews for better presentation
        //
        
        
        self.txtAPIResponse.layer.borderWidth=1
        self.txtAPIResponse.layer.borderColor=UIColor.black.cgColor
        
        //
        // Clear the textviews
        //
       
        txtAPIResponse.text = timeString
        
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
        txtAPIResponse.text = txtAPIResponse.text + "Grant flow set: Password\n"
        //
        // MAS Start with default configruation
        //
        // Only use it for debugging MAS.setGatewayNetworkActivityLogging(true)
        
        txtAPIResponse.text = txtAPIResponse.text + "Starting the MAG SDK\n"
        MAS.start(withDefaultConfiguration: true) { (completed: Bool, error: Error?) in
            
            //
            // Handle the error
            //
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "MAG Start error: \(error.debugDescription)\n"
            }
            
            //
            // Handle the success
            //
            
            if (completed) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "MAG has been successfully started\n"
                self.txtAPIResponse.text = self.txtAPIResponse.text + "MAG Device Stack information:\n"
                self.txtAPIResponse.text = self.txtAPIResponse.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Is the Gateway reachable? : \(MAS.gatewayIsReachable())\n"
                self.deviceStatus()
                self.userStatus()

            }
        }
    }
  


    //
    @IBAction func btnAPICallTapped(_ sender: Any) {
        if MAS.masState() == MASState.didStart {
        if self.txtAPIResponse.text == nil {
            txtAPIResponse.text = ""
        }
        txtAPIResponse.text =  txtAPIResponse.text + "Initiating the GET HTTP Request\n"
        txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/customer/summary/v1] for Customer Full Statement API \n"
    
        // Customer Full Statement thru the MAG SDK

         MAS.getFrom("/customer/summary/v1", withParameters: nil, andHeaders: nil, completion: { (response, error) in

            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
            } else {
                //Update the MAS Log TextView with the latest device registration info
                if self.txtAPIResponse.text == nil {
                    self.txtAPIResponse.text = ""
                }
                self.deviceStatus()
                self.userStatus()
                if self.txtAPIResponse.text == nil {
                    self.txtAPIResponse.text = ""
                }
                self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
                //Add the response to the textView
                self.showdata(respuesta: response! as NSDictionary)
            }
            // Print out the response (JSON from the Gateway)
            // print("API response: \(response?.debugDescription)")
            
            
//            if ((response?.debugDescription) != nil) {
//                self.txtAPIResponse.text = self.txtAPIResponse.text + (response?.debugDescription)!
//            }
            
//            
        })
        } else {
            // Start MAS SDK first
            let mensaje = "Click on 'Start MAS' button first"
            let alert = UIAlertController(title: "Start MAS SDK first", message: mensaje, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func btnAPI2Called(_ sender: Any) {
        if MAS.masState() == MASState.didStart {
        if self.txtAPIResponse.text == nil {
            txtAPIResponse.text = ""
        }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            let timeString = "\(dateFormatter.string(from: Date() as Date))" + "\n"
        txtAPIResponse.text = txtAPIResponse.text + timeString
        txtAPIResponse.text = txtAPIResponse.text + "Initiating the GET HTTP Request\n"
        txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/customer/accounts/v1] for Customer Accounts API\n"
        // GET customer/accounts/v1

        MAS.getFrom("/customer/accounts/v1", withParameters: nil, andHeaders: nil, completion: { (response2, error) in
            
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                
            } else {
            
                //Update the MAS Log TextView with the latest device registration info
                if self.txtAPIResponse.text == nil {
                    self.txtAPIResponse.text = ""
                }
                self.deviceStatus()
                self.userStatus()
                if self.txtAPIResponse.text == nil {
                    self.txtAPIResponse.text = ""
                }
                self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
                //Add the response to the textView
                self.showdata(respuesta: response2! as NSDictionary)
            }
            
            //Print out the response (JSON from the Gateway)
            // print("API response: \(response?.debugDescription)")
           
            
//            if ((response2?.debugDescription) != nil) {
//                self.txtAPIResponse.text = self.txtAPIResponse.text + (response2?.debugDescription)!
//            }
            
        })
    } else {
    // Start MAS SDK first
    let mensaje = "Click on 'Start MAS' button first"
    let alert = UIAlertController(title: "Start MAS SDK first", message: mensaje, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    }
    }

    @IBAction func btnAPI3Called(_ sender: Any) {
        if MAS.masState() == MASState.didStart {
        //
        // /customer/data/v1
        // Personal Customer Information
        if self.txtAPIResponse.text == nil {
            txtAPIResponse.text = ""
        }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            let timeString = "\(dateFormatter.string(from: Date() as Date))" + "\n"
             txtAPIResponse.text = txtAPIResponse.text + timeString
        txtAPIResponse.text = txtAPIResponse.text + "Initiating the GET HTTP Request\n"
        txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/customer/data/v1] for Personal Customer Information API\n"
        
            // GET customer/data/v1

        MAS.getFrom("/customer/data/v1", withParameters: nil, andHeaders: nil, completion: { (response3, error) in
            
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                
            } else {
                
                //Update the MAS Log TextView with the latest device registration info
                if self.txtAPIResponse.text == nil {
                    self.txtAPIResponse.text = ""
                }
                
                self.deviceStatus()
                self.userStatus()
                if self.txtAPIResponse.text == nil {
                    self.txtAPIResponse.text = ""
                }
                self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
                //Add the response to the textViewprint
                self.showdata(respuesta: response3! as NSDictionary)
            }
            //Print out the response (JSON from the Gateway)
            // print("API response: \(response?.debugDescription)")

       
//            if ((response3?.debugDescription) != nil) {
//                self.txtAPIResponse.text = self.txtAPIResponse.text + (response3?.debugDescription)!
//            }
            
        })
        } else {
            // Start MAS SDK first
            let mensaje = "Click on 'Start MAS' button first"
            let alert = UIAlertController(title: "Start MAS SDK first", message: mensaje, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func btnAPIfundsCalled(_ sender: Any) {
        if MAS.masState() == MASState.didStart {
        //
        // /customer/funds/v1
        // Check for funds must return yes / no
        if self.txtAPIResponse.text == nil {
            txtAPIResponse.text = ""
        }
        if let FundstoCheck = Float(txtFundstoCheck.text!) {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            let timeString = "\(dateFormatter.string(from: Date() as Date))" + "\n"
             txtAPIResponse.text = txtAPIResponse.text + timeString
        txtAPIResponse.text = txtAPIResponse.text + "Initiating the GET HTTP Request\n"
        txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/customer/check/funds/v1] for funds with \(FundstoCheck)\n"
        // GET customer/data/v1
/* Endpoint: https://lab002psd2:8443/customer/check/funds/v1
 Input parameters:
 ·         amount
 ·         currency
 ·         iban
 
 Output:
 {
 “amount”: “”,
 “currency”: “”,
 “funds_available”: “yes|no”
 }
 
 Samples:
 https://lab002psd2:8443/customer/check/funds/v1?amount=100&currency=euro&iban=all
 https://lab002psd2:8443/customer/check/funds/v1?amount=100&currency=euro&iban=NUMERO DE UN IBAN
 */

        MAS.getFrom("/customer/check/funds/v1", withParameters: ["amount":txtFundstoCheck.text!,"currency":"euro","iban":"all"], andHeaders: nil, completion: { (response4, error) in
            
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                
            } else {
            self.deviceStatus()
            self.userStatus()
            if self.txtAPIResponse.text == nil {
                self.txtAPIResponse.text = ""
            }
            self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
            //Add the response to the textView
            self.showdata(respuesta: response4! as NSDictionary)
            //Print out the response (JSON from the Gateway)
            // print("API response: \(response?.debugDescription)")
            
//            if ((response4?.debugDescription) != nil) {
//                self.txtAPIResponse.text = self.txtAPIResponse.text + (response4?.debugDescription)!
//            }
            let cuerpo = response4?[MASResponseInfoBodyInfoKey] as! NSDictionary
            if cuerpo["funds_available"] != nil {
                let hasFunds = cuerpo["funds_available"] as! String
                let amount = cuerpo["amount"] as! String
                self.showfunds(hasFunds: hasFunds, amount: amount)
            }
            }
            
        })
        }
        } else {
            // Start MAS SDK first
            let mensaje = "Click on 'Start MAS' button first"
            let alert = UIAlertController(title: "Start MAS SDK first", message: mensaje, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } 
    }

    @IBAction func btnSEPA(_ sender: Any) {
        
        /* SEPA CALL
         
         https://psd2api.demo.ca.com/sepa_test?format=sepa
         https://psd2api.demo.ca.com/sepa_test?format=json
         
         */
        if MAS.masState() == MASState.didStart {
            //
            // sepa call
            //
            if self.txtAPIResponse.text == nil {
                txtAPIResponse.text = ""
            }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            let timeString = "\(dateFormatter.string(from: Date() as Date))" + "\n"
             txtAPIResponse.text = txtAPIResponse.text + timeString
            txtAPIResponse.text = txtAPIResponse.text + "Initiating the GET HTTP Request\n"
            txtAPIResponse.text = txtAPIResponse.text + "-- Calling the protected endpoint at: [/sepa_test with parameter format=sepa] for SEPA API\n"
            
            // GET customer/data/v1
            
            MAS.getFrom("/sepa_test", withParameters: ["format":"sepa"], andHeaders: nil, request: MASRequestResponseType.xml, responseType: MASRequestResponseType.xml, completion: { (response3, error) in
                
                if (error != nil) {
                    self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                    
                } else {
                    
                    //Update the MAS Log TextView with the latest device registration info
                    if self.txtAPIResponse.text == nil {
                        self.txtAPIResponse.text = ""
                    }
                    
                    self.deviceStatus()
                    self.userStatus()
                    if self.txtAPIResponse.text == nil {
                        self.txtAPIResponse.text = ""
                    }
                    self.txtAPIResponse.text = self.txtAPIResponse.text + "HTTP Request Response: ---------->\n"
                    //Add the response to the textViewprint
                    if response3?[MASResponseInfoHeaderInfoKey] != nil {
                        let cabecera = response3?[MASResponseInfoHeaderInfoKey] as! NSDictionary
                        // print("Cabecera:....")
                        
                        self.txtAPIResponse.text = self.txtAPIResponse.text + "Body Response in MASResponseInfoHeaderInfoKey :.... \n"
                        // iterate over all keys
                        
                            
                            self.txtAPIResponse.text = self.txtAPIResponse.text + String(describing: cabecera) + "\n"
                      
                    }
                    if response3?[MASResponseInfoBodyInfoKey] != nil {
                        let cuerpo = response3?[MASResponseInfoBodyInfoKey] as! Data
                      let xml = cuerpo.string
                        // print("Body Response:....")
                        self.txtAPIResponse.text = self.txtAPIResponse.text + "Body Response in MASResponseInfoBodyInfoKey :.... \n"
                     //   print("\(cuerpo)")
                        
                        self.txtAPIResponse.text = self.txtAPIResponse.text + String(describing: xml) + "\n"
                            // print("Key: \(key) - Value: \(value)")
                      //  print("\(response3?[MASResponseInfoBodyInfoKey])")
                        
                        
                    }
                }
                //Print out the response (JSON from the Gateway)
                // print("API response: \(response?.debugDescription)")
                
                
                //            if ((response3?.debugDescription) != nil) {
                //                self.txtAPIResponse.text = self.txtAPIResponse.text + (response3?.debugDescription)!
                //            }
                
            })
        } else {
            // Start MAS SDK first
            let mensaje = "Click on 'Start MAS' button first"
            let alert = UIAlertController(title: "Start MAS SDK first", message: mensaje, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
       
    }
    //
    // Clear the logs
    //
    @IBAction func btnClearLogTapped(_ sender: Any) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        let timeString = "Log cleared at: \(dateFormatter.string(from: Date() as Date))"
        self.txtAPIResponse.text = timeString + "\n"
    }
    
    //
    // Logout the user
    //
    @IBAction func btnLogoutTapped(_ sender: Any) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        let timeString = "\(dateFormatter.string(from: Date() as Date))" + "\n"
         txtAPIResponse.text = txtAPIResponse.text + timeString
        self.txtAPIResponse.text = self.txtAPIResponse.text + "\n------\nPerforming the user logout\n"
       // print(MASUser.current()!)
       if ((MASUser.current()) != nil) {
        MASUser.current().logout { (completed: Bool, error: Error?) in
            //
            // Handle the error
            //
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "User Logout error: \(error.debugDescription)\n"
            }
            
            //Update the MAS Log TextView with the latest device registration info
            self.txtAPIResponse.text = self.txtAPIResponse.text + "The user has been successfully logged out\n"
            self.txtAPIResponse.text = self.txtAPIResponse.text + "MAG Device Stack information:\n"
            self.txtAPIResponse.text = self.txtAPIResponse.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
            self.txtAPIResponse.text = self.txtAPIResponse.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
            
            self.deviceStatus()
            
            self.userStatus()
            self.imgUserStatus.image = #imageLiteral(resourceName: "loggedout")
            self.btnLogout.titleLabel?.text == "Login"
            
            }
       } else {
       
            txtAPIResponse.text = txtAPIResponse.text + "\n------\nUser was not logged in\n"
        }
    }
    
    //
    // De-register the device
    //
    @IBAction func btnDeregisterTapped(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        let timeString = "\(dateFormatter.string(from: Date() as Date))" + "\n"
        txtAPIResponse.text = txtAPIResponse.text + timeString
        txtAPIResponse.text = txtAPIResponse.text + "\n------\nStarting the Device De-registration process\n"
        if MASDevice.current() != nil {
        MASDevice.current().deregister { (completed: Bool, error: Error?) in
            
            //
            // Handle the error
            //
            if (error != nil) {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Device de-registration error: \(error.debugDescription)\n"
            }
            
            self.txtAPIResponse.text = self.txtAPIResponse.text + "\n---------------\n\nThe Device has been successfully de-registered\n"
            self.txtAPIResponse.text = self.txtAPIResponse.text + "MAG Device Stack information:\n"
            self.txtAPIResponse.text = self.txtAPIResponse.text + "-----\n\(MASDevice.current().debugDescription)\n-----\n"
            self.txtAPIResponse.text = self.txtAPIResponse.text + "Is the Device registered? : \(MASDevice.current().isRegistered)\n"
            self.imgDeviceStatus.image = #imageLiteral(resourceName: "unregistered")
            
        }
        } else {
            txtAPIResponse.text = txtAPIResponse.text + "\n------\nDevice was not registered\n"
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
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Is the User authenticated? : \(MASUser.current().isAuthenticated)\n"
                if let atoken = MASUser.current().accessToken {
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Access Token? : \(atoken)\n"
                }
                
            } else {
                
                imgUserStatus.image = #imageLiteral(resourceName: "loggedout")
                self.txtAPIResponse.text = self.txtAPIResponse.text + "Is the User authenticated? : false\n"
                
            }
        }
        
    }
    func showdata(respuesta:NSDictionary) {

       // print("Response \(String(describing: respuesta["MASResponseInfoBodyInfoKey"]))")

        if self.txtAPIResponse.text == nil {
            self.txtAPIResponse.text = ""
        }
        self.txtAPIResponse.text = self.txtAPIResponse.text + String(describing: respuesta["MASResponseInfoBodyInfoKey"]) + "\n"
//        if let JsonObject = try? JSONSerialization.JSONObjectWithData(respuesta.All, options: JSONSerialization.ReadingOptions.MutableContainers) as! NSMutableDictionary{
//            print(JsonObject)
//            //here you can loop through the JsonObject to get the data you are looking for
//            //when you get your array of Games just pass it the the completion closure like this
//       
//        }

    }
    
    func showfunds(hasFunds:String, amount:String) {
        var mensaje = ""
        print("hasFunds: \(hasFunds)")
        mensaje = "User " + MASUser.current().formattedName
        if hasFunds == "yes" {
            mensaje = mensaje + " HAS enough funds"
        } else {
            mensaje = mensaje + " DOESN't have enough funds"
        }
        let alert = UIAlertController(title: "Check Funds API Result", message: mensaje, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // If MAS is not started doen't perform segue to PaymentVC
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "segueToPaymentVC" {
                //login
                var mensaje = ""
                if ((MASUser.current()) == nil) {
                    mensaje = "Execute other API first to log user in"
                    let alert = UIAlertController(title: "Execute other API", message: mensaje, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return false
                }

              if MAS.masState() == MASState.didStart {
                  return true
                } else {
                    // Start MAS SDK first
                    let mensaje = "Click on 'Start MAS' button first"
                    let alert = UIAlertController(title: "Start MAS SDK first", message: mensaje, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return false
                }
                

        }
            return true
    }
        return true
}
}
