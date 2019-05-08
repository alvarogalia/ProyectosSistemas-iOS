//
//  DetalleTextoViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 04-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class DetalleTextoViewController: UIViewController, UITextViewDelegate {

    
    
    //...................................................................//
    //.......................... VARIABLES ..............................//
    //...................................................................//
    
    
    
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    var EDITANDO = false
    var CONTADOR_PALABRAS = Int()
    
    
    //...................................................................//
    //............................ BOTONES ..............................//
    //...................................................................//
    
    
    
    //............................ IBOUTLET .............................//
    
    @IBOutlet weak var txtDato: UITextView!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var numPalabras: UILabel!
    @IBOutlet weak var btnAceptar: UIButton!
    
    
    //............................ IBACTION .............................//
    
    @IBAction func btnCerrar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnGuardar(_ sender: Any) {
        
        SELECTED_TITULO = lblTitulo.text!
        SELECTED_DATO = txtDato.text!
    }
    
    
    
    //...................................................................//
    //.......................... FUNCIONES  .............................//
    //...................................................................//
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitulo.text = SELECTED_TITULO
        txtDato.text = SELECTED_DATO
        CONTADOR_PALABRAS = txtDato.text.lengthOfBytes(using: .utf8)
        
        if(SELECTED_TITULO == "Nombre Proyecto"){
            numPalabras.text! = "\(CONTADOR_PALABRAS) / 200"
        }
        else{
            numPalabras.text! = "\(CONTADOR_PALABRAS) / 3950"
        }
      
            if(EDITANDO){
                txtDato.isEditable = true
                self.btnAceptar.isEnabled = true
                self.btnAceptar.isHidden = false

            }else{
                txtDato.isEditable = false
                self.btnAceptar.isEnabled = false
                self.btnAceptar.isHidden = true
            }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.txtDato.delegate = self
        
        hideKeyboardWhenTappedAround()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //...................................................................//
    //..................... FUNCIONES TEXT VIEW .........................//
    //...................................................................//
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        CONTADOR_PALABRAS = txtDato.text.lengthOfBytes(using: .utf8)
        
        if(SELECTED_TITULO == "Nombre Proyecto"){
            numPalabras.text! = "\(self.CONTADOR_PALABRAS) / 200"
        }
        else{
            numPalabras.text! = "\(self.CONTADOR_PALABRAS) / 3950"
        }

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = txtDato.text!
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        var procede = false
        
        if(SELECTED_TITULO == "Nombre Proyecto"){
            procede = changedText.lengthOfBytes(using: .utf8) <= 200
        }else{
            procede = changedText.lengthOfBytes(using: .utf8) <= 3950
        }
        
        if(procede){
            return procede
        }else{
            let alert = UIAlertController(title: "Excede máximo", message: "El texto ingresado supera el máximo permitido", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return procede
        }
    }
    
    //...................................................................//
    //................. FUNCIONES TECLADO CELULAR .......................//
    //...................................................................//
    @objc func keyboardWillShow(notification: NSNotification) {
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        //self.txtDato.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 70)
    }
}
