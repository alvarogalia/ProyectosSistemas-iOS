//
//  BuscarProyectosTableViewController.swift
//  Proyectos
//
//  Created by Desarrollo on 11-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class Filtro {
    var key = ""
    var value = ""
}

class BuscarProyectosTableViewController: UITableViewController, XMLParserDelegate {

    
    
    
    var items = [Filtro]();
    var item = Filtro();
    var foundCharacters = "";
    let userDefaults = UserDefaults.standard
    var SELECTED_COD_PROYECTO = ""
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    var editando = false
    var heightRow = 50
    
    var mapeo = [0:["Proyecto":"Nombre Proyecto"],
                1:["Dcto_BG":"BG"],
                2:[":Evaluador":"Evaluador"],
                3:["Estatus_Desarrollo":"Estado"],
                4:["Gestion":"Gestion"],
                5:["Facturado":"Facturado"],
                6:["Jefe_Proyecto":"Jp Cliente"],
                7:["JP_SISTEMAS":"Jp Sistemas"],
                8:["Inicio":"Fecha Inicio"],
                9:["Termino":"Fecha Termino"]]
    
   
    
    let texto = ["Proyecto", "Dcto_BG"]
    let picker = ["Evaluador", "Estatus_Desarrollo", "Gestion", "Facturado", "Jefe_Proyecto", "JP_SISTEMAS", "Desarrollador"]
    let numerico = ["Horas", "Total_UF", "SOC", "Orden_de_Compra"]
    let date = ["Inicio", "Termino"]
    let textoLargo = ["Bitacora_Cobranza", "causas_y_atrasos"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
         //print(mapeo[0]?.first?.key)
        hideKeyboardWhenTappedAround()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
                self.tableView.reloadData()
      
    }
    
    
    
 
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapeo.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

  
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProyectosCell", for: indexPath) as! BuscarProyectosTableViewCell
        cell.LblIdentificadorCampo.text = self.mapeo[indexPath.row]?.first?.value

      
       
        
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
  
    
}
