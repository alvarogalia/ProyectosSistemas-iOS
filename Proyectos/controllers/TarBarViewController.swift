//
//  TarBarViewController.swift
//  Proyectos
//
//  Created by Desarrollo on 11-01-18.
//  Copyright © 2018 SistemasSA. All rights reserved.
//

import UIKit

class TarBarViewController: UITabBarController {

    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = (userDefaults.object(forKey: "NombreEmpresa" ) as! String)
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

}
