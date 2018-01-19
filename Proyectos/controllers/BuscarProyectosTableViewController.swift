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

class BuscarProyectosTableViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,  XMLParserDelegate , UITextFieldDelegate , UITableViewDelegate, UITableViewDataSource{
  
    //.............................................................................//
    //.................... REFETENCIAS, VARIABLES Y BOTONES .......................//
    //.............................................................................//
    
    
    @IBOutlet weak var TableViewBuscarProyectos: UITableView!
    @IBOutlet weak var OpcionesBuscarProyectos: UIView!
    @IBOutlet weak var PickerBuscarProyectos: UIPickerView!
    
    @IBAction func BtnSeleccionarOpcion(_ sender: Any) {
        restauraTablePicker()
        ocultarOptionPickerView()
        let cell = TableViewBuscarProyectos.cellForRow(at: self.TableViewBuscarProyectos.indexPathForSelectedRow!) as! BuscarProyectosTableViewCell

        self.CeldasTableview[SELECTED_ROW] = cell.TxtFiltroBusqueda.text!

        
    }
    @IBAction func BtnCancelarOpcion(_ sender: Any) {
        restauraTablePicker()
        ocultarOptionPickerView()

    }
    
    @IBOutlet weak var BarraDeBusqueda: UIView!
    
    
    //-----------------------------------------------------------------------------//
    
    var items = [Filtro]();
    var item = Filtro();
    var foundCharacters = "";
    let userDefaults = UserDefaults.standard
    var SELECTED_COD_PROYECTO = ""
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    var SELECTED_ROW : Int = 0
    var editando = false
    var heightRow = 50
    var posicionBarraBusquedaY = CGFloat(0.0)
    
    //-----------------------------------------------------------------------------//

    var mapeo = [0:["Proyecto":"Nombre Proyecto"],
                1:["Dcto_BG":"BG"],
                2:[":Evaluador":"Evaluador"],
                3:["Estatus_Desarrollo":"Estado"],
                4:["Gestion":"Gestion"],
                5:["Facturado":"Facturado"],
                6:["Jefe_Proyecto":"Jp Cliente"],
                7:["JP_SISTEMAS":"Jp Sistemas"]]
    
    
    //-----------------------------------------------------------------------------//

    let texto = ["Proyecto", "Dcto_BG"]
    let picker = ["Evaluador", "Estado", "Gestion", "Facturado", "Jp Cliente", "Jp Sistemas"]
    let numerico = ["Horas", "Total_UF", "SOC", "Orden_de_Compra"]
    //let date = ["Fecha Inicio", "Fecha Termino"]
    let textoLargo = ["Bitacora_Cobranza", "causas_y_atrasos"]
    
    var CeldasTableview : [Int:String] = [:]
    
    //-----------------------------------------------------------------------------//
    //-----------------------------------------------------------------------------//
    
    
    
    
    
    //.............................................................................//
    //............................... FUNCIONES ...................................//
    //.............................................................................//

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var a = 0
        for _ in mapeo{
            CeldasTableview[a] = ""
            a = a + 1
            
        }
        
        self.TableViewBuscarProyectos.delegate = self
        self.TableViewBuscarProyectos.dataSource = self
        self.PickerBuscarProyectos.dataSource = self
        self.PickerBuscarProyectos.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        hideKeyboardWhenTappedAround()
        
    }
    
    
    
    
    
    //.............................................................................//
    //............................... TABLE VIEW ..................................//
    //.............................................................................//

    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapeo.count
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //-------------------- LLENADO DE LAS CELDAS DE LA TABLA ----------------------//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProyectosCell", for: indexPath) as! BuscarProyectosTableViewCell
     
        cell.LblFiltro.text = self.mapeo[indexPath.row]?.first?.value
        cell.TxtFiltroBusqueda.tag = indexPath.row
        
        cell.TxtFiltroBusqueda.text! = CeldasTableview[indexPath.row]!
        
        if ((cell.LblFiltro.text!) == "Nombre Proyecto" || (cell.LblFiltro.text!) == "BG"){
            cell.TxtFiltroBusqueda.isEnabled = true
            cell.TxtFiltroBusqueda.borderStyle = UITextBorderStyle.roundedRect
        }
        else{
            cell.TxtFiltroBusqueda.isEnabled = false
            cell.TxtFiltroBusqueda.borderStyle = UITextBorderStyle.none
        }
      
     
        cell.TxtFiltroBusqueda.delegate = self
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = TableViewBuscarProyectos.cellForRow(at: indexPath) as! BuscarProyectosTableViewCell
        
            if picker.contains(cell.LblFiltro.text!){
            
                self.TableViewBuscarProyectos.frame = CGRect(x: CGFloat(0.0), y: self.TableViewBuscarProyectos.frame.minY, width: self.view.frame.width, height: self.view.frame.height - self.OpcionesBuscarProyectos.frame.height - 65 - 35)
                    mostrarOptionPickerView()
            }
        SELECTED_ROW = indexPath.row
    }
    
    
    
    //-----------------------------------------------------------------------------//
    //-----------------------------------------------------------------------------//
    
    
    
    

    //.............................................................................//
    //............................. PICKER VIEW .................................//
    //.............................................................................//
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return picker.count
    }
    
    
   
    func restauraTablePicker(){
        self.TableViewBuscarProyectos.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 70 - 65 - 10)
    }
    
    
    
    func pickerView(_ pickerVieckw: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return picker[row]
    }
    
    
    func ocultarOptionPickerView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.OpcionesBuscarProyectos.frame = CGRect(x: 0.0, y: self.view.frame.maxY, width: self.view.frame.width, height: self.OpcionesBuscarProyectos.frame.height)
        }, completion:{ (finished: Bool) in
        })
    }
    
    
    func mostrarOptionPickerView(){
        
        let cell = self.TableViewBuscarProyectos.cellForRow(at: self.TableViewBuscarProyectos.indexPathForSelectedRow!) as! BuscarProyectosTableViewCell
        
        UIView.animate(withDuration: 0.3, animations: {
            self.OpcionesBuscarProyectos.frame = CGRect(x: 0.0, y: self.TableViewBuscarProyectos.frame.maxY, width: self.view.frame.width, height: self.OpcionesBuscarProyectos.frame.height)
        }, completion:{ (finished: Bool) in
            
        })
        
        
        //-------------- MOVER EL TABLE VIEW SEGUN CELDA SELECCIONADA ---------------//
        let cell_framemaxY = cell.frame.maxY
        let tableView_contentOffsetY = TableViewBuscarProyectos.contentOffset.y
        let tableView_frameheight = self.view.frame.height - 70  //tableView.frame.height
        let scroll = CGFloat(200)
        if(tableView_contentOffsetY > 0){
            if(scroll <= tableView_contentOffsetY){
                TableViewBuscarProyectos.contentOffset.y = tableView_frameheight - tableView_contentOffsetY
            }
        }
        let delta = ((tableView_contentOffsetY + tableView_frameheight)-cell_framemaxY)
        if( delta <= 200){
            TableViewBuscarProyectos.contentOffset.y = TableViewBuscarProyectos.contentOffset.y + (200-delta + (cell.frame.height / 2))
        }
    }
    
    
    
    //-----------------------------------------------------------------------------//
    //-----------------------------------------------------------------------------//
    
    
    
    
    
    
    
    //.............................................................................//
    //............................... TECLADO .....................................//
    //.............................................................................//
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height{
            
            ocultarOptionPickerView()
         
            /* 70 es el tamaño de la barra de arriba */
            UIView.animate(withDuration: 0.3, animations: {
                self.TableViewBuscarProyectos.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 70 - keyboardSize)
            }, completion:{ (finished: Bool) in
                
            })
        }
    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
       
        restauraTablePicker()
      
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.CeldasTableview[textField.tag] = textField.text!
    }
    
    
    
    //-----------------------------------------------------------------------------//
    //-----------------------------------------------------------------------------//
    
    
    
    
    
    
    //.............................................................................//
    //............................ OTRAS FUNCIONES ................................//
    //.............................................................................//
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.TableViewBuscarProyectos.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @objc func activarEditar(){
        if(editando){
            editando = false
            ocultarOptionPickerView()
        }else{
            editando = true
        }
        self.TableViewBuscarProyectos.reloadData()
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
}



    //....<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<........>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>....//
    //....<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<.. FIN ..>>>>>>>>>>>>>>>>>>>>>>>>>>>>>....//
    //....<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<........>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>....//
