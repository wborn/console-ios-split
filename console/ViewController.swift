//
//  ViewController.swift
//  or-shell
//
//  Created by Eric Bariaux on 20/01/17.
//  Copyright © 2017 OpenRemote. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import AeroGearHttp

class ViewController: UIViewController {
    
    @IBOutlet weak var loginViewController: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLoginPage(_ sender: Any) {
        let http = Http()
        let keycloakConfig = KeycloakConfig(
            clientId: Client.clientId,
            host: String(format:"http://%@:%@",Server.hostURL,Server.port),
            realm: Server.realm,
            isOpenIDConnect: true)
        keycloakConfig.isWebView = true
        let oauth2Module = AccountManager.addAccountWith(config: keycloakConfig, moduleClass: OAuth2Module.self)
        http.authzModule = oauth2Module
        http.authzModule = oauth2Module
        requestAccess(oauth2Module: oauth2Module)
        
    }
    
    func requestAccess(oauth2Module : OAuth2Module) {
        oauth2Module.requestAccess { (response, error) in
            var token : String
            if response != nil {
                token = response! as! String
                
                let orVC = ORViewcontroller()
                orVC.accessToken = token
                
                self.navigationController?.pushViewController(orVC, animated: true)
            } else if error != nil {
                let alertVC = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.actionSheet)
                let defaultAction = UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                    oauth2Module.requestAuthorizationCode(completionHandler: { (_, error) in
                        self.requestAccess(oauth2Module: oauth2Module)
                    })
                })
                alertVC.addAction(defaultAction)
                
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
}



