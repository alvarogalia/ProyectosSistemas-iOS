//
//  DetalleProyectosTableViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 05-10-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import UIKit



class Proyecto {
    var Proyecto = ""
    var Dcto_BG = ""
    var Estatus_Desarrollo = ""
    var Evaluador = ""
    var Gestion = ""
    var Facturado = ""
    var Jefe_Proyecto = ""
    var JP_SISTEMAS = ""
    var Cod_Proyecto = ""
    var Total_UF = ""
}

class ProyectosTableViewController: UITableViewController, XMLParserDelegate, UISearchBarDelegate {
    

    
    //...................................................................//
    //..................... VARIABLES Y CONSTANTES ......................//
    //...................................................................//
    
    
    
    //........................... VARIABLES .............................//
    
    var items = [Proyecto]();
    var items_resp = [Proyecto]();
    var item = Proyecto();
    var foundCharacters = "";
    var SELECTED_JP_SISTEMAS = "";
    var SELECTED_ESTADO = "";
    var SELECTED_COD_PROYECTO = "";
    var SELECTED_JP_CLIENTES = "";
    var url_ = ""
    var ARRAY_FILTRO : [String:String] = [:]
    var actualizando = false
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let base_url = UserDefaults.standard.value(forKey: "base_url")!
    
    
    
    //...................................................................//
    //............................ BOTONES ..............................//
    //...................................................................//
    
    
    
    //............................ IBOUTLET .............................//
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    //...................................................................//
    //...................... FUNCIONES VIEW .............................//
    //...................................................................//
    
    
    
    
    override func viewDidLoad() {
        
        print("PANTALLA PROYECTOS CARGADA")
        searchBar.delegate = self
        
        let Cod_Empresa = UserDefaults.standard.string(forKey: "Cod_Empresa")!
        
        
        if(self.SELECTED_ESTADO != ""){
            if(self.SELECTED_JP_SISTEMAS != ""){
                url_ = "\(base_url)/getListadoProyectosPorEstadoJPSistemasEmpresa?Cod_Empresa=\(Cod_Empresa )&JP_SISTEMAS=\(self.SELECTED_JP_SISTEMAS.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&estado=\(self.SELECTED_ESTADO.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
            if(self.SELECTED_JP_CLIENTES != ""){
                url_ = "\(base_url)/getListadoProyectosPorEstadoJPClientesEmpresa?Cod_Empresa=\(Cod_Empresa)&JPCliente=\(self.SELECTED_JP_CLIENTES.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&estado=\(self.SELECTED_ESTADO.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
            if(self.SELECTED_JP_CLIENTES == "" && self.SELECTED_JP_SISTEMAS == ""){
                url_ = "\(base_url)/getListadoProyectosPorEstadoEmpresa?Cod_Empresa=\(Cod_Empresa)&txtEstado=\(SELECTED_ESTADO.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            }
        }else{
            url_ = "\(base_url)/getListadoProyectosPorEmpresa?Cod_Empresa=\(Cod_Empresa)"
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadURLandParse), for: .valueChanged)
        tableView.refreshControl = refreshControl
        if(items.count == 0 && actualizando == false){
            loadURLandParse()
        }
    }
    
    //...................................................................//
    //...................... FUNCIONES TABLE VIEW .......................//
    //...................................................................//
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetalleCell", for: indexPath) as! DetalleProyectoTableViewCell
        
        cell.lblDesc.text = items[indexPath.row].Proyecto
        cell.lblIDProyecto.text = items[indexPath.row].Dcto_BG
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
    
    
    
    
    
    //...................................................................//
    //....................... FUNCIONES PARSER ..........................//
    //...................................................................//
    
    
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if (self.ARRAY_FILTRO.count > 0){
            
            for element in ARRAY_FILTRO{
                
                let stringArr = element.value.trim().lowercased().folding(options: .diacriticInsensitive, locale: nil).components(separatedBy: " ")
                let cantidad = stringArr.count
                
                items = items.filter({ (Proyecto) -> Bool in
                    var encontrado = 0
                    if(element.key == "Proyecto"){
                        for item in stringArr{
                            if(Proyecto.Proyecto.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item)) {
                                encontrado = encontrado + 1
                            }
                        }
                        
                    }
                    if(element.key == "Dcto_BG"){
                        for item in stringArr{
                            if(Proyecto.Dcto_BG.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item)){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    if(element.key == "Estatus_Desarrollo"){
                        for item in stringArr{
                            if(Proyecto.Estatus_Desarrollo.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item) && element.value == Proyecto.Estatus_Desarrollo){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    if(element.key == "Evaluador"){
                        for item in stringArr{
                            if(Proyecto.Evaluador.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item) && element.value == Proyecto.Evaluador){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    if(element.key == "Gestion"){
                        for item in stringArr{
                            if(Proyecto.Gestion.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item) && element.value == Proyecto.Gestion){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    if(element.key == "Facturado"){
                        for item in stringArr{
                            if(Proyecto.Facturado.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item) && element.value == Proyecto.Facturado){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    if(element.key == "Jefe_Proyecto"){
                        for item in stringArr{
                            if(Proyecto.Jefe_Proyecto.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item) && element.value == Proyecto.Jefe_Proyecto){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    if(element.key == "JP_SISTEMAS"){
                        for item in stringArr{
                            if(Proyecto.JP_SISTEMAS.lowercased().folding(options: .diacriticInsensitive, locale: NSLocale.current ).contains(item) && element.value == Proyecto.JP_SISTEMAS){
                                encontrado = encontrado + 1
                            }
                        }
                    }
                    
                    
                    
                    if(cantidad == encontrado){
                        
                        return true
                    }else{
                        return false
                    }
                })
                
                items_resp = items
            }
        }
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
            self.item.Dcto_BG = self.foundCharacters
        }
        if elementName == "Estatus_Desarrollo"{
            self.item.Estatus_Desarrollo = self.foundCharacters
        }
        if elementName == "Evaluador"{
            self.item.Evaluador = self.foundCharacters
        }
        if elementName == "Gestion"{
            self.item.Gestion = self.foundCharacters
        }
        if elementName == "Facturado"{
            self.item.Facturado = self.foundCharacters
        }
        if elementName == "Jefe_Proyecto"{
            self.item.Jefe_Proyecto = self.foundCharacters
        }
        if elementName == "JP_SISTEMAS"{
            self.item.JP_SISTEMAS = self.foundCharacters
        }
        
        
        if elementName == "Proyectos" {
            let tempItem = Proyecto();
            
            
            tempItem.Proyecto = self.item.Proyecto
            tempItem.Dcto_BG = self.item.Dcto_BG
            tempItem.Estatus_Desarrollo = self.item.Estatus_Desarrollo
            tempItem.Evaluador = self.item.Evaluador
            tempItem.Gestion = self.item.Gestion
            tempItem.Facturado = self.item.Facturado
            tempItem.Jefe_Proyecto = self.item.Jefe_Proyecto
            tempItem.JP_SISTEMAS = self.item.JP_SISTEMAS
            tempItem.Cod_Proyecto = self.item.Cod_Proyecto
            tempItem.Total_UF = self.item.Total_UF
            
            
            if(self.item.Dcto_BG == ""){
                tempItem.Dcto_BG = "Sin-BG"
            }else{
                tempItem.Dcto_BG = self.item.Dcto_BG
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
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES SEARCH BAR .......................//
    //...................................................................//
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchText == "" {
            items = items_resp
        }
        else{
            
            var items_proyecto = items_resp
            var items_BG = items_resp
            
            items_proyecto = items_proyecto.filter({ (Proyecto) -> Bool in
                let stringArr = searchText.trim().lowercased().folding(options: .diacriticInsensitive, locale: nil).components(separatedBy: " ")
                let cantidad = stringArr.count
                var encontrado = 0
                
                for item in stringArr {
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
                    if(Proyecto.Dcto_BG.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(item)){
                        encontrado = encontrado + 1
                    }
                }
                if(cantidad == encontrado){
                    for proyecto in items_proyecto{
                        if(Proyecto.Cod_Proyecto == proyecto.Cod_Proyecto){
                            return false
                        }
                    }
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
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.tableView.contentOffset.y = 0.0;
        items = items_resp
        self.tableView.reloadData()
        searchBar.text = ""
    }
    
    
    
    //...................................................................//
    //..................... OTRAS FUNCIONES .............................//
    //...................................................................//
    
    
    @objc func loadURLandParse(){
        
        effectView = activityIndicator(title: "Cargando Información", view: self.tableView)
        self.view.isUserInteractionEnabled = false
        let url = URL(string: url_)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if(data != nil){
                let parser = XMLParser(data: data!)
                parser.delegate = (self as XMLParserDelegate)
                self.items.removeAll()
                parser.parse()
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }, completion:{ (finished: Bool) in
                        self.effectView.removeFromSuperview()
                        self.actualizando = false
                    })
                    self.view.isUserInteractionEnabled = true
                }
            }
            else{
                DispatchQueue.main.async {
                    self.effectView.alpha = 0.0
                    self.refreshControl?.endRefreshing()
                    self.effectView.removeFromSuperview()
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
            self.actualizando = true
            task.resume()
        }
        
    }
    
    
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DetalleTableViewController
        destination.SELECTED_COD_PROYECTO = SELECTED_COD_PROYECTO
    }
    
    
    
    @IBAction func unwindActualizarTablaProyectos(segue:UIStoryboardSegue){
        
        let pantalla_hija = segue.source as! DetalleTableViewController

        if(pantalla_hija.ActualizarTabla == true){
            for item in pantalla_hija.items {
                if(item.key == "Proyecto"){
                    self.items[(self.tableView.indexPathForSelectedRow?.row)!].Proyecto = item.value
                }
                if(item.key == "Estatus_Desarrollo"){
                    self.items[(self.tableView.indexPathForSelectedRow?.row)!].Estatus_Desarrollo = item.value
                }
                if(item.key == "Dcto_BG"){
                    self.items[(self.tableView.indexPathForSelectedRow?.row)!].Dcto_BG = item.value
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    
    
}

