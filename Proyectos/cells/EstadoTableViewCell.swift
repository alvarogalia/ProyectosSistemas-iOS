//
//  ProyectosTableViewCell.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 05-10-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import UIKit

class ProyectosTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var lblEstado: UILabel!
    
    @IBOutlet weak var lblCantidad: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
