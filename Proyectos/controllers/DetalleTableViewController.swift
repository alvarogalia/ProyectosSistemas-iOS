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
class DetalleTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    
    
    @IBAction func btnCerrar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEditar(_ sender: Any) {
        activarEditar()
    }
    @IBOutlet weak var btnEditar: UIButton!
    
    var celdas : [String:String] = [:]
    
    var items = [Campo]();
    var item = Campo();
    var foundCharacters = "";
    let userDefaults = UserDefaults.standard
    var SELECTED_COD_PROYECTO = ""
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    var SELECTED_COLNAME = ""
    var editando = false
    var heightRow = 50
    
    let parser_picker = Parser()
    
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
    
    let texto = ["Proyecto", "Dcto_BG"]
    let picker = ["Evaluador", "Estatus_Desarrollo", "Gestion", "Facturado", "Jefe_Proyecto", "JP_SISTEMAS", "Desarrollador"]
    let numerico = ["Horas", "Total_UF", "SOC", "Orden_de_Compra"]
    let date = ["Inicio", "Termino"]
    let textoLargo = ["Bitacora_Cobranza", "causas_y_atrasos"]
    
    let base_url = UserDefaults.standard.value(forKey: "base_url")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        hideKeyboardWhenTappedAround()
        
        
        parser_picker.mapeo = ["Evaluador","Estatus_Desarrollo","Gestion","Facturado","Jefe_Proyecto","JP_SISTEMAS","Desarrollador"]
        let Cod_Empresa = UserDefaults.standard.string(forKey: "Cod_Empresa")!
        parser_picker.parseDatos(URL_: "\(base_url)/getListadoProyectosPorEmpresa?Cod_Empresa=\(Cod_Empresa)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let url = URL(string: "\(base_url)/getListadoProyectosPorCodProyecto?Cod_Proyecto=\(SELECTED_COD_PROYECTO)")
        
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height{
            self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - keyboardSize - 80)
            self.optionView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
            self.dateView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 70)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProyectosCell", for: indexPath) as! DetalleTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let nomColumna = self.items[indexPath.row].key
        let index = indexPath.row
        let campo_aux = self.items[index]
        var dato = campo_aux.value
        
        if editando {
            cell.lblDato.isEnabled = true
            if (numerico.contains(nomColumna)){
                cell.lblDato.keyboardType = UIKeyboardType.decimalPad
            }else if (texto.contains(nomColumna)){
                cell.lblDato.keyboardType = UIKeyboardType.alphabet
            }else {
                cell.lblDato.isEnabled = false
            }
            
            cell.lblIdentificacion.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
            cell.lblDato.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        }else{
            cell.lblDato.isEnabled = false
            cell.lblIdentificacion.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            cell.lblDato.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        }
        if(date.contains(nomColumna)){
            dato = dato.components(separatedBy: " ")[0]
            cell.lblDato.isEnabled = false
        }
        
        
        cell.lblDato.text = dato
        cell.lblDato.tag = indexPath.row
        cell.lblDato.delegate = self
        cell.lblIdentificacion.text = self.mapeo[nomColumna]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! DetalleTableViewCell
        let nomColumna = self.items[indexPath.row].key
        let valor = self.items[indexPath.row].value
        
        SELECTED_DATO = cell.lblDato.text!
        SELECTED_TITULO = cell.lblIdentificacion.text!
        for map in mapeo{
            if(map.value == SELECTED_TITULO){
                self.SELECTED_COLNAME = map.key
            }
        }
        
        if (SELECTED_TITULO == "Bitacora" || SELECTED_TITULO == "Control De Gestion" || SELECTED_TITULO == "Nombre Proyecto")
        {
            performSegue(withIdentifier: "DetalleTextoViewController", sender: self)
        }else if(editando){
            if(picker.contains(nomColumna)){
                self.pickerView.delegate = self
                self.pickerView.dataSource = self
                self.pickerView.reloadAllComponents()

                if let index = self.parser_picker.elementos[SELECTED_COLNAME]?.index(of: SELECTED_DATO){
                    pickerView.selectRow(index, inComponent: 0, animated: true)
                }
                
                
                self.mostrarOptionPickerView()
            }
            if(date.contains(nomColumna)){
                mostrarDateView()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
                dateFormatter.timeZone = TimeZone.current //Current time zone
                let date = dateFormatter.date(from: valor.components(separatedBy: " ")[0])
                datePickerView.date = date!
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightRow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "DetalleTextoViewController"){
            let controller = segue.destination as! DetalleTextoViewController
            controller.SELECTED_DATO = SELECTED_DATO
            controller.SELECTED_TITULO = SELECTED_TITULO
            controller.EDITANDO = editando
        }
    }
    
    @objc func activarEditar(){
        if(editando){
            editando = false
            ocultarOptionPickerView()
            ocultarDateView()
        }else{
            editando = true
        }
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnCancelarGrabar(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        let index = sender.selectedSegmentIndex
        if(index == 0){ //Cancelar
            activarEditar()
        }else if(index == 1){//Grabar
            let alert = UIAlertController(title: "Confirmar Grabar", message: "Los datos ingresados serán actualizados", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Grabar", style: UIAlertActionStyle.destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancelarPicker(_ sender: Any) {
        ocultarOptionPickerView()
    }
    
    @IBAction func btnSeleccionarPicker(_ sender: Any) {
        ocultarOptionPickerView()
        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DetalleTableViewCell
        for map in mapeo{
            if(map.value == cell.lblIdentificacion.text){
                let colName = map.key
                cell.lblDato.text = self.parser_picker.elementos[colName]?[pickerView.selectedRow(inComponent: 0)]
                self.items[self.tableView.indexPathForSelectedRow!.row].value = (self.parser_picker.elementos[colName]?[pickerView.selectedRow(inComponent: 0)])!
            }
        }
    }
    
    @IBAction func btnCancelarDate(_ sender: Any) {
        ocultarDateView()
    }
    
    @IBAction func btnSeleccionarDate(_ sender: Any) {
        ocultarDateView()
        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DetalleTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: self.datePickerView.date)
        cell.lblDato.text = selectedDate
        self.items[self.tableView.indexPathForSelectedRow!.row].value = selectedDate
    }
    
    
    func ocultarOptionPickerView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 65)
            self.optionView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
        }, completion:{ (finished: Bool) in
            
        })
    }
    
    func mostrarOptionPickerView(){
        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DetalleTableViewCell
        
        let cell_framemaxY = cell.frame.maxY
        let tableView_contentOffsetY = tableView.contentOffset.y
        let tableView_frameheight = self.view.frame.height - 70  //tableView.frame.height
        let scroll = CGFloat(200)
        if(tableView_contentOffsetY > 0){
            if(scroll <= tableView_contentOffsetY){
                tableView.contentOffset.y = tableView_frameheight - tableView_contentOffsetY
            }
        }
        let delta = ((tableView_contentOffsetY + tableView_frameheight)-cell_framemaxY)
        if( delta <= 200){
            tableView.contentOffset.y = tableView.contentOffset.y + (200-delta)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - self.optionView.frame.height - 65)
            self.optionView.frame = CGRect(x: 0.0, y: self.view.frame.height - self.optionView.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
            self.dateView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
        }, completion:{ (finished: Bool) in
            
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        self.items[textField.tag].value = textField.text!
    }
    
    func ocultarDateView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 65)
            self.dateView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
        }, completion:{ (finished: Bool) in
            
        })
    }
    
    func mostrarDateView(){
        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DetalleTableViewCell
        let cell_framemaxY = cell.frame.maxY
        let tableView_contentOffsetY = tableView.contentOffset.y
        let tableView_frameheight = self.view.frame.height - 70  //tableView.frame.height
        
        let delta = ((tableView_contentOffsetY + tableView_frameheight)-cell_framemaxY)
        if( delta < 200){
            tableView.contentOffset.y = tableView.contentOffset.y + (200-delta)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.dateView.frame = CGRect(x: 0.0, y: self.view.frame.height - self.optionView.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
            self.optionView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
            self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - self.optionView.frame.height - 65)
        }, completion:{ (finished: Bool) in
            
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let cant = parser_picker.elementos[SELECTED_COLNAME]!.count
        return cant
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let value = parser_picker.elementos[SELECTED_COLNAME]![row]
        return value
    }
}
