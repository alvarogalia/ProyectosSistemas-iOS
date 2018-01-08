//
//  DetalleTextoViewController.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 04-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class DetalleTextoViewController: UIViewController {

    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var txtDato: UITextView!
    
    var SELECTED_TITULO = ""
    var SELECTED_DATO = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitulo.text = SELECTED_TITULO
        txtDato.text = SELECTED_DATO
        
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

}
