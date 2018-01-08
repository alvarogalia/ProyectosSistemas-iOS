//
//  DetalleProyectoTableViewCell.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 05-10-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import UIKit

class DetalleProyectoTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var lblIDProyecto: UILabel!
    @IBOutlet weak var lblEmpresa: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var codProyecto: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
