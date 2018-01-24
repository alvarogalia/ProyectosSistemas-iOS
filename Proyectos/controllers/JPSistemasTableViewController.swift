//
//  JPSistemasTableViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 02-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class JP {
    var Nombre_JP = ""
    var Cantidad = ""
}

class JPSistemasTableViewController: UITableViewController, XMLParserDelegate {
    
    var items = [JP]();
    var item = JP();
    var foundCharacters = "";
    var SELECTED_JP_SISTEMAS = "";
    var SELECTED_JP_CLIENTES = "";
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let Cod_Empresa = UserDefaults.standard.string(forKey: "Cod_Empresa")
    
    @IBOutlet weak var selectorJP: UISegmentedControl!
    
    @IBAction func selectorJPChanged(_ sender: Any) {
        SELECTED_JP_SISTEMAS = ""
        SELECTED_JP_CLIENTES = ""
        loadURLandParse()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadURLandParse), for: .valueChanged)
        tableView.refreshControl = refreshControl
        if(items.count == 0){
            loadURLandParse()
        }
        
    }
    var actualizando = false
    
    @objc func loadURLandParse(){
        var url_ = ""
        if(selectorJP.titleForSegment(at: selectorJP.selectedSegmentIndex) == "JP Sistemas"){
            url_ = "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoJPSistemasPorEmpresa?Cod_Empresa=\(Cod_Empresa ?? "1")"
        }else{
            url_ = "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoJPClientesPorEmpresa?Cod_Empresa=\(Cod_Empresa ?? "1")"
        }
        
        effectView = activityIndicator(title: "Cargando Información", view: self.tableView)
        let url = URL(string: url_)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            self.items.removeAll()
            
            
            self.actualizando = true
            
            if(data != nil){
                let parser = XMLParser(data: data!)
                parser.delegate = (self as XMLParserDelegate)
                self.items.removeAll()
                parser.parse()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.effectView.alpha = 0.0
                        self.refreshControl?.endRefreshing()
                    }, completion:{ (finished: Bool) in
                        self.effectView.removeFromSuperview()
                        self.tableView.reloadData()
                        self.actualizando = false
                    })
                }
            }
            else{
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.effectView.alpha = 0.0
                    self.refreshControl?.endRefreshing()
                    self.effectView.removeFromSuperview()
                    //self.tableView.reloadData()
                    self.actualizando = false
                    
                    self.tableView.contentOffset.y = 0.0
                    
                    
                    let alert = UIAlertController(title: "Error", message: "Problemas de conexión", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
    
    
    override func viewDidLoad() {
        self.tableView.reloadData()
        
        //self.view.addSubview(effectView)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Nombre_JP" {
            self.item.Nombre_JP = self.foundCharacters
        }
        
        if elementName == "Cantidad" {
            self.item.Cantidad = self.foundCharacters
        }
        
        if elementName == "JPSistemas" || elementName == "JPClientes"  {
            let tempItem = JP();
            tempItem.Nombre_JP = self.item.Nombre_JP
            tempItem.Cantidad = self.item.Cantidad
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JPsCell", for: indexPath) as! JPSistemasTableViewCell
        
        cell.lblNombre.text = items[indexPath.row].Nombre_JP
        cell.lblCant.text = items[indexPath.row].Cantidad
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath) as! DetalleProyectoTableViewCell
        if(selectorJP.titleForSegment(at: selectorJP.selectedSegmentIndex) == "JP Sistemas"){
            self.SELECTED_JP_CLIENTES = ""
            self.SELECTED_JP_SISTEMAS = items[indexPath.row].Nombre_JP
        }else{
            self.SELECTED_JP_SISTEMAS = ""
            self.SELECTED_JP_CLIENTES = items[indexPath.row].Nombre_JP
        }
        
        performSegue(withIdentifier: "JPSistemasToEstados", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! EstadosTableViewController
        controller.SELECTED_JP_SISTEMAS = self.SELECTED_JP_SISTEMAS
        controller.SELECTED_JP_CLIENTES = self.SELECTED_JP_CLIENTES
    }
    
    
}

