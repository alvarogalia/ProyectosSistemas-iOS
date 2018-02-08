//
//  DetalleTextoViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 04-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class DetalleTextoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var txtDato: UITextView!
    @IBOutlet weak var lblTitulo: UILabel!
    
    
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    var EDITANDO = false
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitulo.text = SELECTED_TITULO
        txtDato.text = SELECTED_DATO
        
        
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
        
    }

    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height{
            self.txtDato.frame = CGRect(x: self.txtDato.frame.minX, y: self.txtDato.frame.minY, width: self.txtDato.frame.width, height: self.txtDato.frame.height - keyboardSize)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.txtDato.frame = CGRect(x: CGFloat(0.0), y: self.view.frame.minY + 70, width: self.view.frame.width, height: self.view.frame.height - 70)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCerrar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var btnAceptar: UIButton!
    
    @IBAction func btnGuardar(_ sender: Any) {
        
        
        SELECTED_TITULO = lblTitulo.text!
        SELECTED_DATO = txtDato.text!
        print("Dato escrito a mano",SELECTED_DATO)

     
    }
    
   

}
