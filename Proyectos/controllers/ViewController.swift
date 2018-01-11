//
//  ViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 04-10-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import UIKit




class ViewController: UIViewController, XMLParserDelegate {
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnIniciarSesion: UIButton!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    let userDefaults = UserDefaults.standard
    var foundCharacters = ""
    var xmlParser: XMLParser!
    
    var loginSuccess = 0
    override func viewDidAppear(_ animated: Bool) {
        
        if let UserName = UserDefaults.standard.value(forKey: "UserName"){
            if((UserName as! String) != ""){
                performSegue(withIdentifier: "loginSuccess", sender: self)
            }else{
                self.view.isHidden = false
            }
        }else{
            self.view.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true
        hideKeyboardWhenTappedAround()
        loadingIndicator.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnIniciarSesion(_ sender: Any) {
        
        let url = URL(string: "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/fnValidaLogin?usuario=\(txtUserName.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! ?? "")&contrasena=\(txtPassword.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! ?? "")")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            if(data != nil){
                
                self.xmlParser = XMLParser(data: data!)
                self.xmlParser.delegate = self
                self.xmlParser.parse()
                
                DispatchQueue.main.async {
                    self.btnIniciarSesion.isEnabled = true
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    
                    if(self.loginSuccess > 0){
                        self.userDefaults.set(self.txtUserName.text, forKey: "UserName")
                        self.userDefaults.synchronize()
                        self.performSegue(withIdentifier: "loginSuccess", sender: self)
                    }else{
                        let alert = UIAlertController(title: "Error", message: "Credenciales inválidas", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.btnIniciarSesion.isEnabled = true
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    
                    let alert = UIAlertController(title: "Error", message: "Problemas de conexió", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
        
        
        if(txtUserName.text?.trim() != "" && txtPassword.text?.trim() != ""){
            self.btnIniciarSesion.isEnabled = false
            self.loadingIndicator.startAnimating()
            self.loadingIndicator.isHidden = false
            
            task.resume()
        }else{
            let alert = UIAlertController(title: "Error", message: "Credenciales inválidas", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "int" {
            self.loginSuccess = Int(self.foundCharacters)!
        }
        self.foundCharacters = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let value = string.trim();
        if( value != "\n"){
            self.foundCharacters += value;
        }else{
            self.foundCharacters = ""
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
    }
    
}

