//
//  DetalleProyectosTableViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 05-10-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import UIKit

class Proyecto {
    var BG = ""
    var Cod_Proyecto = ""
    var Proyecto = ""
    var Total_UF = ""
    var Estatus_Desarrollo = ""
}

class ProyectosTableViewController: UITableViewController, XMLParserDelegate, UISearchBarDelegate {
    
    var items = [Proyecto]();
    var items_resp = [Proyecto]();
    var item = Proyecto();
    var foundCharacters = "";
    
    var SELECTED_JP_SISTEMAS = "";
    var SELECTED_ESTADO = "";
    var SELECTED_COD_PROYECTO = "";
    var SELECTED_JP_CLIENTES = "";
    var url_ = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewWillAppear(_ animated: Bool) {
        
        let Cod_Empresa = UserDefaults.standard.string(forKey: "Cod_Empresa")
        
        if(self.SELECTED_ESTADO != ""){
            if(self.SELECTED_JP_SISTEMAS != ""){
                url_ = "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoProyectosPorEstadoJPSistemasEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")&JP_SISTEMAS=\(self.SELECTED_JP_SISTEMAS.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&estado=\(self.SELECTED_ESTADO.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
            if(self.SELECTED_JP_CLIENTES != ""){
                url_ = "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoProyectosPorEstadoJPClientesEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")&JPCliente=\(self.SELECTED_JP_CLIENTES.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&estado=\(self.SELECTED_ESTADO.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
            if(self.SELECTED_JP_CLIENTES == "" && self.SELECTED_JP_SISTEMAS == ""){
                url_ = "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoProyectosPorEstadoEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")&txtEstado=\(SELECTED_ESTADO.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
        }else{
            url_ = "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoProyectosPorEmpresa?Cod_Empresa=\(Cod_Empresa ?? "")"
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadURLandParse), for: .valueChanged)
        tableView.refreshControl = refreshControl
        if(items.count == 0 && actualizando == false){
            loadURLandParse()
        }
    }
    var actualizando = false
    
    
    @objc func loadURLandParse(){
        effectView = activityIndicator(title: "Cargando Información", view: self.tableView)
        let url = URL(string: url_)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            self.items.removeAll()
            
            if(data != nil){
                let parser = XMLParser(data: data!)
                parser.delegate = (self as XMLParserDelegate)
                self.items.removeAll()
                parser.parse()
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        //self.effectView.alpha = 0.0
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }, completion:{ (finished: Bool) in
                        self.effectView.removeFromSuperview()
                        self.actualizando = false
                       /* UIView.animate(withDuration: 0.4, animations: {
                            self.tableView.contentOffset.y = -8.0;
                        }, completion: {
                            (value: Bool) in
                        })*/
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
            self.actualizando = true
            task.resume()
        }
    }
    
    override func viewDidLoad() {
        self.tableView.reloadData()
        searchBar.delegate = self
        
        //searchController.delegate = (self as! UISearchControllerDelegate)
        //self.searchBar.alpha = 0.0
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Cod_Proyecto" {
            self.item.Cod_Proyecto = self.foundCharacters
        }
        if elementName == "Proyecto" {
            self.item.Proyecto = self.foundCharacters
        }
        if elementName == "Total_UF" {
            self.item.Total_UF = "UF \(self.foundCharacters)"
        }
        if elementName == "Dcto_BG" {
            self.item.BG = self.foundCharacters
        }
        if elementName == "Estatus_Desarrollo"{
            self.item.Estatus_Desarrollo = self.foundCharacters
        }
        
        if elementName == "Proyectos" {
            let tempItem = Proyecto();
            tempItem.Cod_Proyecto = self.item.Cod_Proyecto
            tempItem.Proyecto = self.item.Proyecto
            tempItem.Total_UF = self.item.Total_UF
            tempItem.Estatus_Desarrollo = self.item.Estatus_Desarrollo
            if(self.item.BG == ""){
                tempItem.BG = "Sin-BG"
            }else{
                tempItem.BG = self.item.BG
            }
            self.items_resp.append(tempItem)
            self.items.append(tempItem)
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
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetalleCell", for: indexPath) as! DetalleProyectoTableViewCell
        cell.lblDesc.text = items[indexPath.row].Proyecto
        cell.lblIDProyecto.text = items[indexPath.row].BG
        cell.codProyecto.text = items[indexPath.row].Cod_Proyecto
        cell.lblEmpresa.text = items[indexPath.row].Estatus_Desarrollo
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DetalleProyectoTableViewCell
        SELECTED_COD_PROYECTO = cell.codProyecto.text!
        self.view.endEditing(true)
        performSegue(withIdentifier: "DetalleProyectosSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DetalleTableViewController
        destination.SELECTED_COD_PROYECTO = SELECTED_COD_PROYECTO
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(self.tableView.contentOffset.y)
        /*
         if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
         UIView.animate(withDuration: 0.5, animations: {
         self.searchBar.alpha = 0.0
         }, completion: {
         (value: Bool) in
         })
         }
         
         if (scrollView.contentOffset.y <= 0){
         UIView.animate(withDuration: 0.5, animations: {
         self.searchBar.alpha = 1.0
         }, completion: {
         (value: Bool) in
         })
         }
         
         if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height)){
         UIView.animate(withDuration: 0.5, animations: {
         self.searchBar.alpha = 0.0
         }, completion: {
         (value: Bool) in
         })
         }*/
    }
    
    
    //------------------------------------------------------------------------------------------//
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            items = items_resp
            
        }
        else{
            
            //let CambioString = searchText.folding(options: .diacriticInsensitive, locale: nil)
            //print(CambioString)
            
            //loadURLandParse()
            var items_proyecto = items_resp
            var items_BG = items_resp
            
            items_proyecto = items_proyecto.filter({ (Proyecto) -> Bool in
                let stringArr = searchText.trim().lowercased().folding(options: .diacriticInsensitive, locale: nil).components(separatedBy: " ")
                let cantidad = stringArr.count
                var encontrado = 0
                
                for item in stringArr{
                    
                    
                    if(Proyecto.Proyecto.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item)){
                        
                        encontrado = encontrado + 1
                    }
                }
                if(cantidad == encontrado){
                    return true
                }else{
                    return false
                }
            })
            
            
            items_BG = items_BG.filter({ (Proyecto) -> Bool in
                let stringArr = searchText.trim().lowercased().folding(options: .diacriticInsensitive, locale: nil).components(separatedBy: " ")
                let cantidad = stringArr.count
                var encontrado = 0
                for item in stringArr{
                    if(Proyecto.BG.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(item)){
                        encontrado = encontrado + 1
                    }
                }
                if(cantidad == encontrado){
                    return true
                }else{
                    return false
                }
            })
            
            
            items.removeAll()
            
            for item_x in items_proyecto {
                items.append(item_x)
            }
            for item_x in items_BG {
                items.append(item_x)
            }
            
        }
        
        self.tableView.reloadData()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        //self.searchBar.alpha = 0.0
        self.tableView.contentOffset.y = 0.0;
        //let cgrect = CGRect(x: self.searchBar.frame.minX, y: self.searchBar.frame.minY, width: self.view.frame.width, height: 0.0)
        //self.searchBar.frame = cgrect
        
        items = items_resp
        self.tableView.reloadData()
        
        searchBar.text = ""
    }
    
}

