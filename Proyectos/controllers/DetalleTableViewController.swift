//
//  DetalleProyectoTableViewController.swift
//  detallesProyectos
//
//  Created by Desarrollo on 04-01-18.
//  Copyright © 2018 Desarrollo. All rights reserved.
//

import UIKit

class Campo {
    var key = ""
    var value = ""
}
class DetalleTableViewController: UITableViewController, XMLParserDelegate {
    
    var items = [Campo]();
    var item = Campo();
    var foundCharacters = "";
    let userDefaults = UserDefaults.standard
    var SELECTED_COD_PROYECTO = ""
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    
    var mapeo = ["Proyecto":"Nombre Proyecto",
                 "Dcto_BG":"BG",
                 "Evaluador":"Evaluador",
                 "Estatus_Desarrollo":"Estado",
                 "Gestion":"Gestion",
                 "Facturado":"Facturado",
                 "Jefe_Proyecto":"Jp Cliente",
                 "JP_SISTEMAS":"Jp Sistemas",
                 "Desarrollador":"Desarrollador",
                 "Horas":"Total De Horas",
                 "Total_UF":"Total UF",
                 "SOC":"Cesta",
                 "Orden_de_Compra":"OC",
                 "Inicio":"Fecha Inicio",
                 "Termino":"Fecha Termino",
                 "Bitacora_Cobranza":"Bitacora",
                 "causas_y_atrasos":"Control De Gestion"]
    
    override func viewWillAppear(_ animated: Bool) {
        let url = URL(string: "http://200.111.46.182/WS_MovilProyecto/MovilProyecto.asmx/getListadoProyectosPorCodProyecto?Cod_Proyecto=\(SELECTED_COD_PROYECTO)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in            
            let parser = XMLParser(data: data!)
            parser.delegate = (self as XMLParserDelegate)
            parser.parse()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        if(items.count == 0){
            task.resume()
        }
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        let keyExists = mapeo[elementName]
        if keyExists != nil {
            let campo_aux = Campo()
            campo_aux.key = elementName
            campo_aux.value = self.foundCharacters
            items.append(campo_aux)
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
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProyectosCell", for: indexPath) as! DetalleTableViewCell
        let nomColumna = self.items[indexPath.row].key
        cell.lblIdentificacion.text = self.mapeo[nomColumna]
        let index = indexPath.row
        let campo_aux = self.items[index]
        let dato = campo_aux.value
        cell.lblDato.text = dato
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DetalleTableViewCell
        SELECTED_DATO = cell.lblDato.text!
        SELECTED_TITULO = cell.lblIdentificacion.text!
        if (SELECTED_TITULO == "Bitacora" || SELECTED_TITULO == "Control De Gestion" || SELECTED_TITULO == "Nombre Proyecto")
        {
            performSegue(withIdentifier: "ProyectosSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier != "editarSegue"){
            let controller = segue.destination as! DetalleTextoViewController
            controller.SELECTED_DATO = SELECTED_DATO
            controller.SELECTED_TITULO = SELECTED_TITULO
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar", style: .plain, target: self, action: #selector(activarEditar))
    }
    
    @objc func activarEditar(){
        performSegue(withIdentifier: "editarSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

