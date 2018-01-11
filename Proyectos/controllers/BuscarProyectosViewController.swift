//
//  BuscarProyectosViewController.swift
//  Proyectos
//
//  Created by Desarrollo on 10-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class Estado{
    var EstadoProyecto = ""
}

class BuscarProyectosViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,  XMLParserDelegate {
    

    
    //--------------------------TXT------------------------------//
    
    @IBOutlet weak var TxtNombre: UITextField!
    @IBOutlet weak var TxtBG: UITextField!
    @IBOutlet weak var TxtOC: UITextField!
    
    //------------------------Picker-----------------------------//

    @IBOutlet weak var PickerEvaluador: UIPickerView!
    @IBOutlet weak var PickerEstado: UIPickerView!
    @IBOutlet weak var PickerGestion: UIPickerView!
    @IBOutlet weak var PickerFacturado: UIPickerView!
    @IBOutlet weak var PickerJpSistemas: UIPickerView!
    @IBOutlet weak var PickerJpCliente: UIPickerView!
    
    //------------------------Date Picker------------------------//

    @IBOutlet weak var DPickerFechaInicio: UIDatePicker!
    @IBOutlet weak var DPickerFechaTermino: UIDatePicker!
    
    //------------------------Label------------------------------//

    @IBOutlet weak var LblCantidadProyectos: UILabel!
    
    
    //-----------------------------------------------------------//

    @IBAction func BtnBuscar(_ sender: Any) {
        print(self.TxtNombre.text!)
        print(self.TxtBG.text!)
        print(self.TxtOC.text!)
    }
    
    @IBAction func BtnLimpiar(_ sender: Any) {
       
        viewDidLoad()
    }
    
    
    var ArrayEstados = ["","Cotizacion BG", "Cotizacion Descartada", "Detenido por Cliente", "En Desarrollo", "En espera paso a produccion", "En espera puesta en test", "En Produccion", "En Pruebas de Usuarios Cliente","Finalizado y Detenido por Cliente"]
    var ArrayJpClientes = ["","Alvaro","Cristian","yethro","Barbara"]
    var ArrayJpSistemas = ["","felipe","Jose Luis","Maria","Hector"]
    var ArrayFacturado = ["","si","no","tal vez","quizas"]
    var ArrayEvaluador = ["","Pedro","JUAN","Diego","Pablo"]
    var ArrayGestion = ["","solicitud Das","Solicitud Hito 1","Saldo por Facturar","Con OC"]
    
    
    var aux = 0
    var aux2 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PickerJpSistemas.tag = 6
        PickerJpCliente.tag = 5
        PickerFacturado.tag = 4
        PickerEvaluador.tag = 3
        PickerGestion.tag = 2
        PickerEstado.tag = 1
  
        self.PickerEstado.delegate = self
        self.PickerEstado.dataSource = self
        self.PickerGestion.delegate = self
        self.PickerGestion.dataSource = self
        self.PickerEvaluador.delegate = self
        self.PickerEvaluador.dataSource = self
        self.PickerFacturado.delegate = self
        self.PickerFacturado.dataSource = self
        self.PickerJpCliente.delegate = self
        self.PickerJpCliente.dataSource = self
        self.PickerJpSistemas.delegate = self
        self.PickerJpSistemas.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
   
  
   
    
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        print(pickerView.tag)
        
        switch (pickerView.tag)
        {
        case 1: do {
            return self.ArrayEstados.count
            }
            
        case 2: do {
            return self.ArrayGestion.count
            }
        case 3: do {
            return self.ArrayEvaluador.count
            }
        case 4: do {
            return self.ArrayFacturado.count
            }
        case 5: do {
            return self.ArrayJpClientes.count
            }
        case 6: do {
            return self.ArrayJpSistemas.count
            }
        default:
            print("ERROR")
        }
        
     return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch (pickerView.tag)
        {
        case 1: do{
            return ArrayEstados[row]
            }
            
        case 2: do{
            return ArrayGestion[row]
            }
        case 3: do{
            return ArrayEvaluador[row]
            }
        case 4: do{
            return ArrayFacturado[row]
            }
        case 5: do{
            return ArrayJpClientes[row]
            }
        case 6: do{
            return ArrayJpSistemas[row]
            }
        default:
            print("ERROR")
        }
        return ""
    }
   /*
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        /*if (row == 0){
            self.view.backgroundColor = UIColor.orange
        }else if (row == 1){
            
            self.view.backgroundColor = UIColor.blue
        }else if (row == 2){
            self.view.backgroundColor = UIColor.yellow
        }else{
            self.view.backgroundColor = UIColor.cyan
        }*/
        
        
            //print (ArrayPicker[0])
      
            //print (ArrayPicker[1])
   
    }
        
   */
    /*
    override func viewWillAppear(_ animated: Bool) {
        url_ = "http://192.168.255.6/WS_MovilProyecto/MovilProyecto.asmx/    getListadoEstadosPorEmpresa"
     
     
        if(items.count == 0){
            //loadURLandParse()
        }
    }
*/
    
   
}
