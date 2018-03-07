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
    
    
    //...................................................................//
    //..................... VARIABLES Y CONSTANTES ......................//
    //...................................................................//
    

    
    //.......................... CONSTANTES .............................//
    
    let userDefaults = UserDefaults.standard
    let parser_picker = Parser()
    let texto = ["Dcto_BG"]
    let numerico = ["Horas", "Total_UF", "SOC", "Orden_de_Compra"]
    let date = ["Inicio", "Termino"]
    let textoLargo = ["Bitacora_Cobranza", "causas_y_atrasos","Proyecto"]
    let base_url = UserDefaults.standard.value(forKey: "base_url")!
    let picker = ["Evaluador", "Estatus_Desarrollo", "Gestion", "Facturado", "Jefe_Proyecto","JP_SISTEMAS", "Desarrollador"]
    
    //........................... VARIABLES .............................//
    
    var items = [Campo]();
    var item = Campo();
    var foundCharacters = "";
    var SELECTED_COD_PROYECTO = "";
    var SELECTED_TITULO = "";
    var SELECTED_DATO = "";
    var SELECTED_COLNAME = "";
    var editando = false;
    var heightRow = 50;
    var efecto = false;
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var CamposExcedidos = [String]()
    var Formato_Float = [String]()
    var ActualizarTabla = false
    
    var mapeo = ["Proyecto":"Nombre Proyecto",
                 "Dcto_BG":"BG",
                 "Evaluador":"Evaluador",
                 "Estatus_Desarrollo":"Estado",
                 "Gestion":"Gestion",
                 "Facturado":"Facturado",
                 "Jefe_Proyecto":"Jp Cliente",
                 "JP_SISTEMAS":"Jp Sistemas",
                 "Desarrollador":"Desarrollador",
                 "Horas":"Total de Horas",
                 "Total_UF":"Total UF",
                 "SOC":"Cesta",
                 "Orden_de_Compra":"OC",
                 "Inicio":"Fecha Inicio",
                 "Termino":"Fecha Termino",
                 "Bitacora_Cobranza":"Bitacora",
                 "causas_y_atrasos":"Control de Gestion"]
    
    

    //...................................................................//
    //............................ BOTONES ..............................//
    //...................................................................//
    
    
    
    //............................ IBOUTLET .............................//
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var btnEditar: UIButton!

    
    //............................ IBACTION .............................//   
    
    @IBAction func btnEditar(_ sender: Any) {
        activarEditar()
        
        var CAMPOS_CORRECTOS = false
        
        if((sender as! UIButton).titleLabel?.text == "Editar"){
            (sender as! UIButton).setTitle("Guardar", for: .normal)
        }
        
        
        if((sender as! UIButton).titleLabel?.text == "Guardar"){
          
            CAMPOS_CORRECTOS = Validar_Campos()
            
            if(CAMPOS_CORRECTOS == false){
                print(Generar_Mensaje_Error())
                let alert = UIAlertController(title: "Error", message: Generar_Mensaje_Error() , preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                editando = true
                CamposExcedidos.removeAll()
            }
            else{
                
                let url = URL(string: Generar_URL())
                
                effectView = activityIndicator(title: "Modificando datos", view: self.view)
                self.view.addSubview(effectView)
                let task_Modificar = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    // SI EL STATUSCODE ES 200 SI MODIFICO EL PROYECTO
                    // SI ES 500, EXISTEN PROBLEMAS
                    if(httpResponse?.statusCode == 200){
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Modificación Exitosa", message: "proyecto modificado correctamente", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.ActualizarTabla = true
                            self.effectView.removeFromSuperview()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "Problemas al modificar datos", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Reintentar", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.effectView.removeFromSuperview()
                        }
                    }
                }
                tableView.reloadData()
                task_Modificar.resume()
                (sender as! UIButton).setTitle("Editar", for: .normal)
            }
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
    
    
    
    
    @IBAction func unwindLaWea(segue:UIStoryboardSegue){
        let pantalla_hija = segue.source as! DetalleTextoViewController
        let campo_aux = self.items[self.tableView.indexPathForSelectedRow!.row] as Campo
        campo_aux.value = pantalla_hija.SELECTED_DATO
        self.items[self.tableView.indexPathForSelectedRow!.row].value = campo_aux.value
       
        
        self.tableView.reloadData()
    }
    
    
    
    
    @IBAction func btnCancelarDate(_ sender: Any) {
        ocultarDateView()
    }
    
   
    
    
    @IBAction func btnSeleccionarDate(_ sender: Any) {
        ocultarDateView()
        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DetalleTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let selectedDate = dateFormatter.string(from: self.datePickerView.date)
        cell.lblDato.text = selectedDate
        self.items[self.tableView.indexPathForSelectedRow!.row].value = selectedDate
    }
    
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES VIEW .............................//
    //...................................................................//
    
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
        parser_picker.parseDatos(URL_: "\(base_url)/getListadoProyectosPorEmpresa?Cod_Empresa=\(Cod_Empresa)",Vista: self)
        
        self.view.isUserInteractionEnabled = false
        
        let url = URL(string: "\(base_url)/getListadoProyectosPorCodProyecto?Cod_Proyecto=\(SELECTED_COD_PROYECTO)")
        effectView = activityIndicator(title: "cargando información", view: self.tableView)
        self.view.addSubview(effectView)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let parser = XMLParser(data: data!)
            parser.delegate = (self as XMLParserDelegate)
            parser.parse()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.effectView.removeFromSuperview()
            }
        }
        
        if(items.count == 0){
            task.resume()
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = true
        self.effectView.removeFromSuperview()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.effectView.removeFromSuperview()
    }
    
    
    
    
    
    //...................................................................//
    //..................... FUNCIONES TEXT FIELD ........................//
    //...................................................................//
    
    
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        let aux = textField
      
        if(Verificar_Largo_Dato(Identificador: self.items[textField.tag].key, Dato: textField.text!) == false){
            aux.textColor = UIColor.red
            self.items[textField.tag].value = aux.text!
        }
        else{
            if((self.items[textField.tag].key == "Horas" || self.items[textField.tag].key == "Total_UF") && Validar_Formato_Float(Dato: textField.text!) == false){
                aux.textColor = UIColor.red
                self.items[textField.tag].value = aux.text!
            }
            else{
                aux.textColor = UIColor.black
                self.items[textField.tag].value = aux.text!
            }
        }
        
    }
   
    
    
    
    //...................................................................//
    //...................... FUNCIONES TABLE VIEW .......................//
    //...................................................................//
    
    
    
    
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
        
        cell.lblDato.text! = dato
        cell.lblDato.tag = indexPath.row
        cell.lblDato.delegate = self
        cell.lblIdentificacion.text = self.mapeo[nomColumna]
        
        
        if(Verificar_Largo_Dato(Identificador: nomColumna, Dato: dato) == false){
            cell.lblDato.textColor = UIColor.red
            if(nomColumna == "Horas" || nomColumna == "Total_UF"){
                if(Validar_Formato_Float(Dato: dato) == false){
                    cell.lblDato.textColor = UIColor.red
                }
            }
            
            
        }
        else{
            cell.lblDato.textColor = UIColor.black
            
            if(nomColumna == "Horas" || nomColumna == "Total_UF"){
                if(Validar_Formato_Float(Dato: dato) == false){
                    cell.lblDato.textColor = UIColor.red
                }
            }
        }
        
        if(cell.lblIdentificacion.text! == "Proyecto" && cell.lblDato.text! != ""){
            efecto = true
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! DetalleTableViewCell
        let nomColumna = self.items[indexPath.row].key
        let valor = self.items[indexPath.row].value
        
        SELECTED_DATO = valor
        SELECTED_TITULO = cell.lblIdentificacion.text!
        for map in mapeo{
            if(map.value == SELECTED_TITULO){
                self.SELECTED_COLNAME = map.key
            }
        }
        
        if (SELECTED_TITULO == "Bitacora" || SELECTED_TITULO == "Control de Gestion" || SELECTED_TITULO == "Nombre Proyecto")
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
    
    
    
    
    //...................................................................//
    //........................ FUNCIONES PICKER .........................//
    //...................................................................//
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let cant = parser_picker.elementos[SELECTED_COLNAME]!.count
        return cant
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let value = parser_picker.elementos[SELECTED_COLNAME]![row]
        return value
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func mostrarOptionPickerView(){
        let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DetalleTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
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
    
    
    
    
    func ocultarOptionPickerView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 65)
            self.optionView.frame = CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: self.optionView.frame.height)
        }, completion:{ (finished: Bool) in
            
        })
    }
    
    
    
    
    
    //...................................................................//
    //...................... FUNCIONES DATE VIEW ........................//
    //...................................................................//
    
    
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
    
    
    
    
    
    //...................................................................//
    //................. FUNCIONES TECLADO CELULAR .......................//
    //...................................................................//
    
    
    
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
    
    
    
    //...................................................................//
    //....................... FUNCIONES PARSER ..........................//
    //...................................................................//
    
    
    
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
    
    
    
    //...................................................................//
    //................. FUNCIONES EDITAR PROYECTO........................//
    //...................................................................//
    
    
    
    
    // Verifica el largo del dato ingresado
    func Verificar_Largo_Dato (Identificador :String, Dato :String) ->Bool {
        
        
        if(Identificador == "Bitacora_Cobranza" || Identificador == "causas_y_atrasos"){
            if(Dato.count <= 3950){
                return true
            }
        }
        
        
        if(Identificador == "Proyecto" || Identificador == "Evaluador" || Identificador == "Estatus_Desarrollo" || Identificador == "Gestion" || Identificador == "Facturado" || Identificador == "Jefe_Proyecto" || Identificador == "JP_SISTEMAS" || Identificador == "Desarrollador"){
            if(Dato.count <= 255){
                return true
            }
        }
        if(Identificador == "Orden_de_Compra"){
            if(Dato.count <= 53){
                return true
            }
        }
        if(Identificador == "Dcto_BG" || Identificador == "SOC"){
            if(Dato.count <= 50){
                return true
            }
        }
        if(Identificador == "Inicio" || Identificador == "Termino" ){
            if(Dato.count <= 11){
                return true
            }
        }
        if(Identificador == "Total_UF" || Identificador == "Horas" ){
            if(Dato.count <= 8){
                return true
            }
        }
        return false
    }
    
    
    
    
    // Corta la cadena si se exede del largo maximo (NO SE UTILIZA)
    func Cortar_Dato (Identificador :String, Dato :String) ->String {
        
        var resultado = String()
        
        if(Identificador == "Proyecto" || Identificador == "Evaluador" || Identificador == "Estatus_Desarrollo" || Identificador == "Gestion" || Identificador == "Facturado" || Identificador == "Jefe_Proyecto" || Identificador == "JP_SISTEMAS" || Identificador == "Desarrollador"){
            resultado = String(Dato.dropLast(Dato.count-255))
            return resultado
        }
        
        if(Identificador == "Orden_de_Compra"){
            resultado = String(Dato.dropLast(Dato.count-53))
            return resultado
        }
        
        if(Identificador == "Dcto_BG" || Identificador == "SOC"){
            resultado = String(Dato.dropLast(Dato.count-50))
            return resultado
        }
        
        if(Identificador == "Total_UF" || Identificador == "Horas" ){
            resultado = String(Dato.dropLast(Dato.count-8))
            return resultado
        }
        return Dato
    }
    
    
    
    // Cambio de formato para que lo reciba la base (formato: yyyy/dd/mm)
    func ChangeDateFormat (Date: String) -> String {
        let ArrayDate = Date.components(separatedBy: "/")
        var StringDate = String()
        StringDate = StringDate + ArrayDate[0] + "/" + ArrayDate[2] + "/" +  ArrayDate[1]
        return StringDate
    }
    
    // Cambio de caracter en caso de que encuentre alguna comilla simple sola
    func ChangeStringFormat (cadena: String) -> String {
        let newString = cadena.replacingOccurrences(of: "'", with: "''")
        return newString
    }
    
    
    
    
    // Valida que los campos float no posean 2 puntos en sus datos
    func Validar_Formato_Float (Dato: String) -> Bool{
        
        let myStringArr = Dato.components(separatedBy: ".")
        
            if(myStringArr.count > 2){
                return false
            }
        
        return true
    }
    
    
    
    // Valida que todos los campos cumplan con su formato
    func Validar_Campos () -> Bool{
        
        var Contador_Campos_Correctos = 0
        var Contador_Formato_Float = 0
        
        for elemento in items {
            
            if(elemento.key == "Proyecto" || elemento.key == "Evaluador" || elemento.key == "Estatus_Desarrollo" || elemento.key == "Gestion" || elemento.key == "Facturado" || elemento.key == "Jefe_Proyecto" || elemento.key == "JP_SISTEMAS" || elemento.key == "Desarrollador"){
                if(elemento.value.count <= 255){
                    Contador_Campos_Correctos = Contador_Campos_Correctos + 1
                }
            }
            
            if(elemento.key == "Orden_de_Compra"){
                if(elemento.value.count <= 53){
                    Contador_Campos_Correctos = Contador_Campos_Correctos + 1
                }
            }
            
            if(elemento.key == "Dcto_BG" || elemento.key == "SOC"){
                if(elemento.value.count <= 50){
                    Contador_Campos_Correctos = Contador_Campos_Correctos + 1
                }
            }
            
            if(elemento.key == "Total_UF" || elemento.key == "Horas" ){
            
                if(Validar_Formato_Float(Dato: elemento.value)){
                    Contador_Formato_Float = Contador_Formato_Float + 1
                }
                
                if(elemento.value.count <= 8){
                    Contador_Campos_Correctos = Contador_Campos_Correctos + 1
                }
            }
        }
        
        if(Contador_Campos_Correctos == 13 && Contador_Formato_Float == 2){
            return true
        }
        
        return false
    }
    
    
    
    
    // Genera un String con todos los campos que exceden el largo
    func Generar_String_Campos_Excedidos () -> String{
        var Aux = String()
        
        for elemento in CamposExcedidos{
            for elementoMapa in mapeo{
                
                if(elemento == elementoMapa.key){
                    Aux = Aux + ", " + elementoMapa.value
                }
            }
        }
        
        if(Aux.count > 2){
            Aux.remove(at: Aux.startIndex)
            return Aux
        }
        return " "
    }
    
    
    // Genera un String con todos los campos que poseen formato erroneo
    func Generar_String_Formato_Erroneo() -> String{
        
        var Aux = String()
        
        for elemento in Formato_Float{
            for elementoMapa in mapeo{
                
                if(elemento == elementoMapa.key){
                    Aux = Aux + ", " + elementoMapa.value
                }
            }
        }
        
        if(Aux.count > 2){
            Aux.remove(at: Aux.startIndex)
            return Aux
        }
        return " "
    }
    
    
    // Genera mensaje de error con sus respectivos campos erroneos
    func Generar_Mensaje_Error () -> String{
        
        self.CamposExcedidos.removeAll()
        var Contador_Formato_String = 0
        var Aux = String()
        
        for elementos in items{
            if(Verificar_Largo_Dato(Identificador: elementos.key, Dato: elementos.value) == false){
                self.CamposExcedidos.append(elementos.key)
            }
            if(elementos.key == "Horas" || elementos.key == "Total_UF"){
                if(Validar_Formato_Float(Dato: elementos.value) == false){
                    Contador_Formato_String = Contador_Formato_String + 1
                    self.Formato_Float.append(elementos.key)
                }
            }
            
        }
        
        if(CamposExcedidos.count >= 1){
            if(CamposExcedidos.count > 1){
                Aux = "Campos: " + Generar_String_Campos_Excedidos() + "\nexceden largo\n\n"
            }
            else{
                Aux = "Campo: " + Generar_String_Campos_Excedidos() + " excede largo\n\n"
            }
        }
        
        if(Formato_Float.count >= 1){
            if(Formato_Float.count > 1){
                Aux = Aux + "Campos: " + Generar_String_Formato_Erroneo() + "\nposeen caracter '.' extra"
            }
            else{
                Aux = Aux + "Campo: " + Generar_String_Formato_Erroneo() + " posee caracter '.' extra"
            }
        }
        
        self.Formato_Float.removeAll()
        self.CamposExcedidos.removeAll()
        
        return Aux
    }
    
    
    
    
    
    // Genera la url del proyecto ha modificar
    func Generar_URL () -> String{
        
        var stringAux : String
        var UrlModificar_Base = "\(base_url)/setActualizarProyectoQuery?"
        var UrlModificar_Parametros = ""
        
        for elementos in items {
                if(elementos.key == "Inicio" || elementos.key == "Termino"){
                    UrlModificar_Parametros = UrlModificar_Parametros + elementos.key + "="
                    stringAux = ChangeDateFormat(Date: elementos.value)
                    UrlModificar_Parametros = UrlModificar_Parametros + stringAux.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&"
                }
                else{
                    UrlModificar_Parametros = UrlModificar_Parametros + elementos.key + "="
                    stringAux = ChangeStringFormat(cadena: elementos.value)
                     UrlModificar_Parametros = UrlModificar_Parametros + stringAux.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&"
                }
        }
        
        for elem in mapeo{
            if(UrlModificar_Parametros.contains(elem.key) == false){
                UrlModificar_Parametros = UrlModificar_Parametros + "&" + elem.key + "=" + ""
            }
        }
        
        let aux = userDefaults.string(forKey: "UserName")! as String
        UrlModificar_Parametros = UrlModificar_Parametros + "Usuario_Modifica=\(aux)"+"&"
        UrlModificar_Parametros = UrlModificar_Parametros + "Cod_Proyecto=\(SELECTED_COD_PROYECTO)"
        
        UrlModificar_Base = UrlModificar_Base + UrlModificar_Parametros
       
        print(UrlModificar_Base)
        
        return UrlModificar_Base
    }
    
    
    
    //...................................................................//
    //..................... OTRAS FUNCIONES .............................//
    //...................................................................//
    
    
    
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "DetalleTextoViewController"){
            let controller = segue.destination as! DetalleTextoViewController
            controller.SELECTED_DATO = SELECTED_DATO
            controller.SELECTED_TITULO = SELECTED_TITULO
            controller.EDITANDO = editando
        }
    }
  
}
