//
//  funciones.swift
//  Proyectos
//
//  Created by Alvaro Galia Valenzuela on 27-12-17.
//  Copyright © 2017 SistemasSA. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

func getDataFromUrl(urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
    URLSession.shared.dataTask(with: urL as URL) { (data, response, error) in
        completion(data as Data?)
        }.resume()
}

func activityIndicator(title: String, view: UIView) -> UIVisualEffectView {
    
    let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 220, height: 46))
    strLabel.text = title
    strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
    strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 220, height: 46)
    effectView.layer.cornerRadius = 15
    effectView.layer.masksToBounds = true
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
    activityIndicator.startAnimating()
    
    effectView.contentView.addSubview(activityIndicator)
    effectView.contentView.addSubview(strLabel)
    return effectView
}

func downloadImage(_ uri : String, inView: UIImageView, indicador : UIActivityIndicatorView){
    let url = URL(string: uri)
    
    let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
        if(error == nil){
            if let resp = response as? HTTPURLResponse {
                if(resp.statusCode == 200){
                    if let data = responseData {
                        DispatchQueue.main.async {
                            let imagen = UIImage(data: data)
                            let urlArr = uri.components(separatedBy: "/")
                            let last = urlArr.count - 1
                            let imageName: String = urlArr[last]
                            UserDefaults.standard.set(data, forKey: imageName)
                            inView.image = imagen
                            indicador.stopAnimating()
                            indicador.isHidden = true
                        }
                    }else {
                        DispatchQueue.main.async {
                            inView.image = #imageLiteral(resourceName: "edificio")
                            indicador.stopAnimating()
                            indicador.isHidden = true
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        inView.image = #imageLiteral(resourceName: "edificio")
                        indicador.stopAnimating()
                        indicador.isHidden = true
                    }
                }
            }else{
                DispatchQueue.main.async {
                    inView.image = #imageLiteral(resourceName: "edificio")
                    indicador.stopAnimating()
                    indicador.isHidden = true
                }
            }
        }else{
            DispatchQueue.main.async {
                inView.image = #imageLiteral(resourceName: "edificio")
                indicador.stopAnimating()
                indicador.isHidden = true
            }
        }
    }
    
    task.resume()
    indicador.startAnimating()
}
