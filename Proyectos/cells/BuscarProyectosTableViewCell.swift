//
//  BuscarProyectosTableViewCell.swift
//  Proyectos
//
//  Created by Desarrollo on 11-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class BuscarProyectosTableViewCell: UITableViewCell {

    @IBOutlet weak var LblIdentificadorCampo: UILabel!
    
    @IBOutlet weak var TxtFiltro: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
