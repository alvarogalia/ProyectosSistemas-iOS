//
//  JPSistemasTableViewCell.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 02-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class JPSistemasTableViewCell: UITableViewCell {

    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblCant: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
