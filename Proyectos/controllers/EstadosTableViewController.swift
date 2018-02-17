//
//  ProyectosTableViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 04-10-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import UIKit



class Estados {
    var Estatus_Desarrollo = ""
    var Cantidad = ""
}



class EstadosTableViewController: UITableViewController, XMLParserDelegate {
    
    
    
    
    //...................................................................//
    //..................... VARIABLES Y CONSTANTES ......................//
    //...................................................................//
    
    
    //.......................... CONSTANTES .............................//
    
    
    let userDefaults = UserDefaults.standard
    
    
    //........................... VARIABLES .............................//
    
    
    var items = [Estados]();
    var item = Estados();
    var foundCharacters = "";
    var SELECTED_JP_SISTEMAS = "";
    var SELECTED_JP_CLIENTES = "";
    var SELECTED_ESTADO = "";
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var url_ = ""
    var actualizando = false
    let base_url = UserDefaults.standard.value(forKey: "base_url")!
    
    
    //...................................................................//
    //...................... FUNCIONES VIEW .............................//
    //...................................................................//
    
    
    
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        self.tableView.reloadData()
        
        
        let Cod_Empresa = userDefaults.string(forKey: "Cod_Empresa")
        if(self.SELECTED_JP_SISTEMAS == "" && self.SELECTED_JP_CLIENTES == ""){
            url_ = "\(base_url)/getListadoEstadosPorEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")"
        }else{
            if(self.SELECTED_JP_CLIENTES != ""){
                url_ = "\(base_url)/getListadoEstadosPorJPClientesEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")&JPCliente=\(self.SELECTED_JP_CLIENTES.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! )"
            }
            if(self.SELECTED_JP_SISTEMAS != ""){
                url_ = "\(base_url)/getListadoEstadosPorJPSistemasEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")&JP_SISTEMAS=\(self.SELECTED_JP_SISTEMAS.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! )"
            }
            
        }
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadURLandParse), for: .valueChanged)
        tableView.refreshControl = refreshControl
        if(items.count == 0){
            loadURLandParse()
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES TABLE VIEW .......................//
    //...................................................................//
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProyectosCell", for: indexPath) as! ProyectosTableViewCell
        cell.lblEstado.text = self.items[indexPath.row].Estatus_Desarrollo
        cell.lblCantidad.text = self.items[indexPath.row].Cantidad
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProyectosTableViewCell
        self.SELECTED_ESTADO = cell.lblEstado.text!
        performSegue(withIdentifier: "ProyectosSegue", sender: self)
    }
    
    
    
    
    //...................................................................//
    //..................... FUNCIONES PARSER ............................//
    //...................................................................//
    
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Estatus_Desarrollo" {
            self.item.Estatus_Desarrollo = self.foundCharacters
        }
        if elementName == "Cantidad" {
            self.item.Cantidad = self.foundCharacters
        }
        if elementName == "Estados" {
            let tempItem = Estados();
            tempItem.Cantidad = self.item.Cantidad
            tempItem.Estatus_Desarrollo = self.item.Estatus_Desarrollo
            self.items.append(tempItem);
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
    
    
    
    
    //...................................................................//
    //..................... OTRAS FUNCIONES .............................//
    //...................................................................//
    
    
    @objc func loadURLandParse(){
        effectView = activityIndicator(title: "Cargando Información", view: self.tableView)
        let url = URL(string: url_)
        self.view.isUserInteractionEnabled = false
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            self.items.removeAll()
            self.actualizando = true
            
            if(data != nil){
                let parser = XMLParser(data: data!)
                parser.delegate = (self as XMLParserDelegate)
                self.items.removeAll()
                parser.parse()
                
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.effectView.alpha = 0.0
                        self.refreshControl?.endRefreshing()
                    }, completion:{ (finished: Bool) in
                        self.effectView.removeFromSuperview()
                        self.tableView.reloadData()
                        self.actualizando = false
                    })
                    self.view.isUserInteractionEnabled = true
                }
            }
            else{
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.effectView.alpha = 0.0
                    self.refreshControl?.endRefreshing()
                    self.effectView.removeFromSuperview()
                    self.tableView.reloadData()
                    self.actualizando = false
                    
                    self.tableView.contentOffset.y = 0.0
                    
                    let alert = UIAlertController(title: "Error", message: "Problemas de conexión", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                  self.view.isUserInteractionEnabled = true
                    self.loadURLandParse()
                }
                
            }
        }
        
        if(self.refreshControl?.isRefreshing != true){
            self.navigationController?.view.addSubview(self.effectView)
        }
        
        if(self.actualizando == false){
            task.resume()
        }else{
            task.cancel()
            self.effectView.removeFromSuperview()
            task.resume()
        }
    }
    
   
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ProyectosTableViewController
        controller.SELECTED_ESTADO = self.SELECTED_ESTADO
        controller.SELECTED_JP_SISTEMAS = self.SELECTED_JP_SISTEMAS
        controller.SELECTED_JP_CLIENTES = self.SELECTED_JP_CLIENTES
        
    }
    
}

