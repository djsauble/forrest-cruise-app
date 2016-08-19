//
//  LoginViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/19/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import SwiftWebSocket

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var tokenText: UITextField!
    @IBOutlet weak var getTokenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tokenText.delegate = self
        self.tokenText.becomeFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        fetchURL()
        return false
    }
    
    func fetchURL() {
        let token = self.tokenText.text!
        let ws = WebSocket()
        ws.event.open = {
            ws.send("{\"type\": \"passcode:use\", \"data\": {\"passcode\": \"\(token)\"} }")
        }
        ws.event.message = { message in
            let data = String(message).dataUsingEncoding(NSUTF8StringEncoding)
            do {
                // Deserialize the JSON response
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                // Update the credentials
                FileManager.singleton.setCredentialsForUser(
                    object["data"]!!["user"] as! String,
                    token: object["data"]!!["token"] as! String
                )
                
                // Unwind to the previous view
                self.tokenText.resignFirstResponder()
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            catch {
                // Recover
            }
            ws.close()
        }
        ws.event.close = { code, reason, clean in
            self.tokenText.text = ""
        }
        ws.event.error = { err in
            ws.close()
        }
        if (RemoteAPI.ws.hasPrefix("wss")) {
            ws.allowSelfSignedSSL = true
        }
        ws.open(RemoteAPI.ws)
    }
}
