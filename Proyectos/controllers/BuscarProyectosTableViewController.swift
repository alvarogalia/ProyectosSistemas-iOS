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
    
    
    
    //...................................................................//
    //..................... VARIABLES Y CONSTANTES ......................//
    //...................................................................//
    
    
    
    //.......................... CONSTANTES .............................//
    
    
    
    let userDefaults = UserDefaults.standard
    let picker = ["Evaluador", "Estado", "Gestion", "Facturado", "Jp Cliente", "Jp Sistemas"]
    let parser_picker = Parser()
    let base_url = UserDefaults.standard.value(forKey: "base_url")!
    
    
    //........................... VARIABLES .............................//
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var foundCharacters = "";
    var SELECTED_COD_PROYECTO = ""
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    var SELECTED_ROW : Int = 0
    var SELECTED_COLNAME = ""
    var editando = false
    var heightRow = 50
    var posicionBarraBusquedaY = CGFloat(0.0)
    var CeldasTableview : [Int:String] = [:]
    var Parche = false
    var mapeo = [0:["Proyecto":"Nombre Proyecto"],
                 1:["Dcto_BG":"BG"],
                 2:["Evaluador":"Evaluador"],
                 3:["Estatus_Desarrollo":"Estado"],
                 4:["Gestion":"Gestion"],
                 5:["Facturado":"Facturado"],
                 6:["Jefe_Proyecto":"Jp Cliente"],
                 7:["JP_SISTEMAS":"Jp Sistemas"]]
    
    
    //...................................................................//
    //............................ BOTONES ..............................//
    //...................................................................//
    
    
    
    //............................ IBOUTLET .............................//
    
    
    
    @IBOutlet weak var TableViewBuscarProyectos: UITableView!
    @IBOutlet weak var OpcionesBuscarProyectos: UIView!
    @IBOutlet weak var PickerBuscarProyectos: UIPickerView!
    @IBOutlet weak var BarraDeBusqueda: UIView!
    
    
    //............................ IBACTION .............................//
    
    
    
    @IBAction func BtnSeleccionarOpcion(_ sender: Any) {
        restauraTablePicker()
        ocultarOptionPickerView()
        let cell = TableViewBuscarProyectos.cellForRow(at: self.TableViewBuscarProyectos.indexPathForSelectedRow!) as! BuscarProyectosTableViewCell
        
        self.CeldasTableview[SELECTED_ROW] = cell.TxtFiltroBusqueda.text!
        
        let element = mapeo[(self.TableViewBuscarProyectos.indexPathForSelectedRow?.row)!]
        
        for el in element!{
            let colName = el.key
            cell.TxtFiltroBusqueda.text = self.parser_picker.elementos[colName]?[PickerBuscarProyectos.selectedRow(inComponent: 0)]
            self.CeldasTableview[self.TableViewBuscarProyectos.indexPathForSelectedRow!.row] = (self.parser_picker.elementos[colName]?[PickerBuscarProyectos.selectedRow(inComponent: 0)])!
        }
    }
    
    
    
    @IBAction func BtnCancelarOpcion(_ sender: Any) {
        restauraTablePicker()
        ocultarOptionPickerView()
    }
    
    
    
    @IBAction func BtnLimpiar(_ sender: Any) {
        var i = 0
        while i < CeldasTableview.count{
            CeldasTableview[i] = ""
            i = i + 1
        }
        TableViewBuscarProyectos.reloadData()
        PickerBuscarProyectos.reloadAllComponents()
    }
    
    
    
    @IBAction func BtnLimpiarPicker(_ sender: Any) {
        let cell = TableViewBuscarProyectos.cellForRow(at: self.TableViewBuscarProyectos.indexPathForSelectedRow!) as! BuscarProyectosTableViewCell
        cell.TxtFiltroBusqueda.text = ""
        self.CeldasTableview[self.TableViewBuscarProyectos.indexPathForSelectedRow!.row] = ""
        PickerBuscarProyectos.reloadAllComponents()
    }
    
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES VIEW .............................//
    //...................................................................//
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var a = 0
        for _ in mapeo{
            CeldasTableview[a] = ""
            a = a + 1
        }
        
        
        parser_picker.mapeo = ["Evaluador","Estatus_Desarrollo","Gestion","Facturado","Jefe_Proyecto","JP_SISTEMAS","Desarrollador"]
        
        let Cod_Empresa = UserDefaults.standard.string(forKey: "Cod_Empresa")!
        
        self.effectView = activityIndicator(title: "Cargando Información", view: self.view)
        self.view.addSubview(self.effectView)
        self.view.isUserInteractionEnabled = false
        parser_picker.parseDatos(URL_: "\(base_url)/getListadoProyectosPorEmpresa?Cod_Empresa=\(Cod_Empresa)",Vista: self)
        
        self.TableViewBuscarProyectos.delegate = self
        self.TableViewBuscarProyectos.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        hideKeyboardWhenTappedAround()
        
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.TableViewBuscarProyectos.reloadData()
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
       
        
    }
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES TABLE VIEW .......................//
    //...................................................................//
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapeo.count
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
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
        
        self.SELECTED_COLNAME = (self.mapeo[indexPath.row]?.first?.key)!
        self.PickerBuscarProyectos.dataSource = self
        self.PickerBuscarProyectos.delegate = self
        self.PickerBuscarProyectos.reloadAllComponents()
        
        if picker.contains(cell.LblFiltro.text!){
            
            self.TableViewBuscarProyectos.frame = CGRect(x: CGFloat(0.0), y: self.TableViewBuscarProyectos.frame.minY, width: self.view.frame.width, height: self.view.frame.height - self.OpcionesBuscarProyectos.frame.height - 65 - 35)
            mostrarOptionPickerView()
        }
        SELECTED_ROW = indexPath.row
        
    }
    
    
    
    
    
    //...................................................................//
    //........................ FUNCIONES PICKER .........................//
    //...................................................................//
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Para verificar que no sea proyecto o bg
        if(SELECTED_COLNAME != "Proyecto" && SELECTED_COLNAME != "Dcto_BG"){
            let value = parser_picker.elementos[SELECTED_COLNAME]![row]
            return value
        }
        return nil
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Para verificar que no sea proyecto o bg
        if(SELECTED_COLNAME != "Proyecto" && SELECTED_COLNAME != "Dcto_BG"){
            let cant = parser_picker.elementos[SELECTED_COLNAME]!.count
            return cant
        }
        return 1
    }
    
    
    func restauraTablePicker(){
        self.TableViewBuscarProyectos.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 70 - 65 - 10 )
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
    
    
    //...................................................................//
    //................. FUNCIONES TECLADO CELULAR .......................//
    //...................................................................//
    
    
    
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
    
    
    
    //...................................................................//
    //..................... FUNCIONES TEXT FIELD ........................//
    //...................................................................//
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.CeldasTableview[textField.tag] = textField.text!
    }
    
    
    
    
    //...................................................................//
    //..................... OTRAS FUNCIONES .............................//
    //...................................................................//
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MuestraResultado")
        {
            var ARRAY_FILTRO : [String:String] = [:]
            for map in mapeo{
                if(CeldasTableview[map.key]?.trim() != "" && CeldasTableview[map.key] != nil){
                    ARRAY_FILTRO[(map.value.first?.key)!] = CeldasTableview[map.key]
                }
            }
            let destination = segue.destination as! ProyectosTableViewController
            destination.ARRAY_FILTRO = ARRAY_FILTRO
            
        }
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
}


