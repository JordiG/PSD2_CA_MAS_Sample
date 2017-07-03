//
//  PaymentVC.swift
//  MAS Sandbox
//
//  Created by JORDI GASCON on 05/05/2017.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI
import SwiftyJSON


class PaymentVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var totalBalance = 0.00
    var availBalance = 0.00
    var avBal: Double = 0.00
    var totBal: Double = 0.00
    var accts = [String]()
    var tbalances = [String]()
    var abalances = [String]()
    var acctsnum: String = ""
    var acctSelected: String = ""
    var logmessage: String = ""
    var alerta: UIAlertController!

    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblCurrBalance: UILabel!
    @IBOutlet weak var lblAvailBalance: UILabel!
    @IBOutlet weak var lblAvailBalanceNum: UILabel!
    
    @IBOutlet weak var txtPaymentAmount: UITextField!
    @IBOutlet weak var txtPaymentDescription: UITextField!
    
    @IBOutlet weak var tableAccounts: UITableView!
    @IBOutlet weak var txtToAcct: UITextField!
    
    
    @IBAction func ButtonBackpressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        let timeString = "PaymentVC dismissed at: \(dateFormatter.string(from: Date() as Date))" + "\n"
        SharingLog.sharedInstance.logMessage = logmessage + timeString
        dismiss(animated: true)
    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
        logmessage = SharingLog.sharedInstance.logMessage
        self.txtPaymentAmount.delegate = self
        self.txtPaymentDescription.delegate = self
        self.txtToAcct.delegate = self
        
        txtPaymentAmount.keyboardType = UIKeyboardType.numbersAndPunctuation
        

    }
    override func viewDidAppear(_ animated: Bool) {
        logmessage = SharingLog.sharedInstance.logMessage
         // SharingLog.sharedInstance.logMessage = logmessage + "Paso por Payment VC \n"
          //   print ("logmessage en PaymentVC vale: \(logmessage)")
      let titulo = "Gathering Data for user" + MASUser.current().formattedName
        self.notifyUser(title: titulo, message: "Retrieving bank accounts", timeToDissapear: 1)
                cargardatoscuentas() 
    
    }
    
    
    @IBAction func ButtonExecutePRessed(_ sender: Any) {
        
        // check if from account is selected:
        print("Paso por Execute")
        
        if tableAccounts.indexPathsForSelectedRows != nil {
        
        //
        var cantidad = 0.00
        if txtPaymentAmount.text != "" {
            if let cantidade = Double(txtPaymentAmount.text!) {
                cantidad = cantidade
                print("Cantidad \(cantidad)")
            }
        }
        if cantidad > 0 && cantidad > availBalance {
            // mensaje de error no tiene suficiente.
        }
        
        // esto esta a piñon... de momento... y dejar cuenta destino
        var frmacct = "DE209129513238398850100"
        if acctSelected != "" {
            frmacct = acctSelected
        }
        // let toacct =  "DE81370400440532013000"
        let toacct = txtToAcct?.text ?? ""
        let currency = "EUR"
        let description = txtPaymentDescription?.text ?? "No Description"
        let amnt = txtPaymentAmount?.text ?? "0"
         print("toacct: \(toacct)")
         print("description: \(description)")
         print("frmacct \(frmacct)")
         print("amnt: \(amnt)")
        
       logmessage = logmessage + "-- Calling the protected endpoint at: [/customer/payment/initiate/v1] for Payment Initiation with parameters: \n"
       logmessage = logmessage + "FromAcct:\(frmacct) ToAcct \(toacct) Currency \(currency) Description \(description) TransferAmt \(amnt) \n"
        
        MAS.post(to: "/customer/payment/initiate/v1", withParameters: ["FromAcct":frmacct,"ToAcct":toacct,"Currency":currency,"Description":description,"TransferAmt":amnt], andHeaders: nil, completion: { (iniresponse, error) in
            
            // chequear error
            
            if (error != nil) {
                print("Se ha producido un error en la llamada a MAS.post initiate")
                print(error.debugDescription)
                self.logmessage = self.logmessage + "Error calling /customer/payment/initiate/v1 : \(error.debugDescription) \n"
                
            } else {
                
                // ejecutar transaccion
                let cuerpo = iniresponse?[MASResponseInfoBodyInfoKey] as! NSDictionary
                if cuerpo["trx_id"] != nil {
                    let trxid = cuerpo["trx_id"] as! String
                    print("trxid vale: \(trxid)")
                    self.logmessage = self.logmessage + "Got transaction id (trx_id) code: \(trxid) \n"
                    // init execution get token:
                    // execute payment (async)
                   self.executepayment(trx: trxid) { result in
                       print("the result is = \(result)")
                    }
                
                }
                
            }
        })
        } else {
            
            let mensaje: String = "Payment Account origin needs to be selected"
        
            let alert = UIAlertController(title: "Payment Account", message: mensaje, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func cargardatoscuentas() {
        if let atoken = MASUser.current()?.accessToken {
            //    self.txtAPIResponse.text = self.txtAPIResponse.text + "Access Token? : \(atoken)\n"
            print("token: \(atoken)")
            logmessage = logmessage + ("using token: \(atoken) \n")
            
        } else {
        
            print("no token")
            logmessage = logmessage + ("No token. Log in first \n")

            self.dismiss(animated: false)
           
            MASUser.presentLoginViewController(completion: { (response, error) in
                if (error != nil) {
                    print(error!)
                    self.dismiss(animated: false)
                } else {
                    print(response)
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC")
                    self.show(next!, sender: (Any).self)
                    
                    let atoken = MASUser.current()?.accessToken
                    print("atoken: \(atoken)")
                }
            })
        }
        
        

           // pedir pantalla
        logmessage = logmessage + "-- Calling the protected endpoint at: [/customer/accounts/v1] for gathering customer accounts: \n"
        
            // read accounts
            MAS.getFrom("/customer/accounts/v1", withParameters: nil, andHeaders: nil, completion: { (response, error) in
                
                if (error != nil) {
                    // self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                    self.logmessage = self.logmessage + "Error calling /customer/accounts/v1: \(error.debugDescription) \n"
                    
                } else {
                    if let usuario = MASUser.current().familyName {
                        self.lblUser.text = "User: \(usuario)"
                    } else {
                        self.lblUser.text = ""
                    }
                    let cuerpo = response?[MASResponseInfoBodyInfoKey] as! NSDictionary
                    //Add the response to the textView
                    // self.showdata(respuesta: response2! as NSDictionary)
                    
                    if cuerpo["accounts"] != nil {
                        
                        let json = JSON(cuerpo["accounts"])
                        let i = json.count
                        print("la array tiene \(i)")
                        let u = i as Int
                        self.accts.removeAll()
                        self.abalances.removeAll()
                        self.tbalances.removeAll()
                        for x in 0..<u {
                            //print("json de \(x) tiene \(json[x])")
                            //print("json de AcctNum \(x) tiene \(json[x]["AcctNum"])")
                            self.acctsnum = String(describing: json[x]["AcctNum"])
                            self.accts.append(self.acctsnum)
                            
                            self.avBal = json[x]["AvailableBalance"].doubleValue
                            self.totBal = json[x]["CurrentBalance"].doubleValue
                            
                            self.abalances.append(String(describing: self.avBal))
                            self.tbalances.append(String(describing: self.totBal))
                            
                            print("json de CurrentBalance \(x) tiene \(json[x]["CurrentBalance"])")
                            self.availBalance = self.availBalance + self.avBal
                            self.totalBalance = self.totalBalance + self.totBal
                        }
                        print("total Avail Balance: \(self.availBalance)")
                        print("AcctsNum: \(self.accts)")
                        print("Available balance per account: \(self.abalances)")
                        print("Total BAlance per account: \(self.tbalances)")
                        //self.lblCurrBalance.text = "Current Balance: \(totalBalance)"
                        let formattedBal = String(format: "%.2f", locale: Locale.current, Double(self.totalBalance))
                        self.lblCurrBalance.text = "Current Balance: \(formattedBal)"
                        //someLabel.text = NSString(format:"%d", someVar)
                        let formattedavail = String(format: "%.2f", locale: Locale.current, Double(self.availBalance))
                        self.lblAvailBalanceNum.text = "\(formattedavail)" + "€"
                        // print("\(cuerpo["accounts"])")
                        
                        /* execute payment
                         "FromAcct":"DE209129513238398850100",
                         "ToAcct":"DE81370400440532013000",
                         "Currency":"EUR",
                         "Description": "Buy a book",
                         "TransferAmt": "100"
                         */
                        print("Paso por cargar data")
                        self.tableAccounts.reloadData()
                        
                    }
                }
                //
            })
            }


    func executepayment(trx: String, completionHandler: @escaping (Int) -> Void) {
        DispatchQueue.global().async {
            // slow calculations performed here
           
            
            DispatchQueue.main.async {
                 // let result = 200 //OK a piñon
                self.logmessage = self.logmessage + "-- Calling the protected endpoint at: [/customer/payment/execute/v1] for Payment Execution with parameters: \n"
                self.logmessage = self.logmessage + "trx_id: \(trx) \n"
                
                MAS.put(to: "/customer/payment/execute/v1", withParameters: ["trx_id":trx], andHeaders: nil, completion: { (exeresponse, error) in
                    
                    // chequear error
                    
                    if (error != nil) {
                        // self.txtAPIResponse.text = self.txtAPIResponse.text + "Error calling the API: \(error.debugDescription)\n"
                        print("Se ha producido un error en la llamada a MAS.post execute")
                        print(error)
                        self.logmessage = self.logmessage + "Error calling Execute API: \(error.debugDescription) \n"
                        
                    } else {
                        print("Se ha ejecutado el pago y esta es la respuesta")
                        let cuerpo = exeresponse?[MASResponseInfoBodyInfoKey] as! NSDictionary
                        var isOK = false
                        if cuerpo["TransId"] != nil {
                            let tr_response = cuerpo["TransId"]
                            let amount = cuerpo["TransferAmt"]

                            //let tr_response = cuerpo["TransId"] as! String
                            //let amount = cuerpo["TransferAmt"] as! String
                            isOK = true
                        } else {
                            // error code?
                        }

                        self.logmessage = self.logmessage + "Call Payment Execute API succeeded. Response: \(exeresponse?.debugDescription) \n"
                        
                        var mensaje: String = "Payment "
                        if isOK == true {
                           // mensaje = mensaje + "of \(cuerpo["TransferAmt"]!)€" + " approved and executed \n Trans Id: \(cuerpo["TransId"]!)"
                            mensaje = mensaje + "of \(cuerpo["TransferAmt"]!)€" + " approved and executed"
                        } else {
                            mensaje = mensaje + " denied"
                        }
                        let alert = UIAlertController(title: "Payment Execution Result", message: mensaje, preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                        
                        print(exeresponse)
                        completionHandler(200)
                    }
                    })
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "celda"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AcctTableViewCell
        if accts.count > 0 {
            let formattedBal1 = String(format: "%.2f", locale: Locale.current, Double(tbalances[indexPath.row])!)
            let formattedBal2 = String(format: "%.2f", locale: Locale.current, Double(abalances[indexPath.row])!)
            cell.totalBalCell?.text = "Total: " + formattedBal1
            cell.acctNumCell?.text = "Acct Num: " + accts[indexPath.row]
            cell.availBalCell?.text = "Available: " + formattedBal2
            
            print("Paso por display: \(indexPath.row)")
        }
        print("paso indexpathrow \(indexPath.row)")
        // Configure the cell...
      //  cell.textLabel?.text = restaurantNames[indexPath.row]
      //  cell.imageView?.image = UIImage(named: "restaurant.jpg")
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("celdas: \(accts.count)")
        return self.accts.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! AcctTableViewCell
        
        print("Seleccionada: \(indexPath.row)")
        acctSelected = accts[indexPath.row]
        print("available balance vale: \(availBalance)")
       // cell.totalBalCell?.text = abalances[indexPath.row]
       // cell.totalBalCell.Tex[indexPath.row]
        // cell.thumbnailImageView.image = UIImage(named: restaurantImages[indexPath.row])
       // cell.bgImage.image = UIImage(named: "selected or unselected")
    }

    // HAcer que el teclado se oculte si se pulsa return sin introducir nada o se hace tap fuera de el teclado
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)

     }
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //        texto.resignFirstResponder() // cambiar texto por el nombre que se le haya dado a campo field
        self.view.endEditing(true)
        return false
       }
    // set the UIAlerController property
    
    
    func notifyUser(title: String, message: String, timeToDissapear: Int) -> Void
    {
        print("Notifying user")
        alerta = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
         self.present(alerta, animated: true, completion: nil)
        
        alerta.addAction(cancelAction)
        // self.navigationController?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alerta.dismiss(animated: false, completion: nil)
        }
    }
    
}

