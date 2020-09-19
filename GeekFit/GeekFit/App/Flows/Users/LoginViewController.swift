//
//  LoginController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 07.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable redundant_discardable_let

import UIKit
import RxSwift
import RxCocoa

@objc(LoginViewController)
class LoginViewController: UIViewController {
    @IBOutlet weak var lblErrorMessage: UILabel! {
        didSet {
            lblErrorMessage.layer.cornerRadius = 10
            lblErrorMessage.layer.borderColor = UIColor.systemRed.cgColor
            lblErrorMessage.layer.borderWidth = 1
            lblErrorMessage.clipsToBounds = true
            lblErrorMessage.isHidden = true
        }
    }
    
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnEnter: UIButton! {
        didSet {
            btnEnter.isEnabled = false
        }
    }
    
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    
    var service = UserService.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // На этом экране навигация не нужна
        navigationController?.navigationBar.isHidden = true
        
        // Убираем клавиатуру по клику на форму
        let touchGuesture = UITapGestureRecognizer(target: self, action: #selector(onViewClick))
        self.view.addGestureRecognizer(touchGuesture)
        
        // Включаем наблюдение за заполненностью полей логин/пароль
        configureButtonEnterClicked()
    }
    
    // Настройка наблюдения за полями логин/пароль
    private func configureButtonEnterClicked() {
        let _ = Observable
            .combineLatest(txtLogin.rx.text, txtPassword.rx.text)
            .map { (login, password) in
                return (!(login ?? "").isEmpty && (password ?? "").count >= 4)
        }
        .bind { [weak btnEnter] fieldNotEmpty in
            btnEnter?.isEnabled = fieldNotEmpty
        }
    }
    
    @objc
    private func onViewClick() {
        self.view.endEditing(true)
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        // Скрываем сообщение об ошибке
        self.lblErrorMessage.isHidden = true
        
        // Проверяем наличие необходимых данных
        guard let login = txtLogin.text, login.isEmpty == false,
            let password = txtPassword.text, password.isEmpty == false else {
                return
        }
        
        // Проверяем пользователя
        guard service.getUserWith(login: login, password: password) == true else {
            self.lblErrorMessage.layer.opacity = 0
            self.lblErrorMessage.isHidden = false
            
            // Моргнем плашкой об ошибке
            UIView.animate(withDuration: 2, animations: {
                self.lblErrorMessage.layer.opacity = 1
            }, completion: { _ in
                UIView.animate(withDuration: 2) {
                    self.lblErrorMessage.layer.opacity = 0
                }
            })
            
            return
        
        }
        
        // Пользователь найден - поставим флаг
        UserDefaults.standard.set(true, forKey: "isLogin")
        
        // Осуществим переход на главный экран
        onLogin?()
    }
        
    @IBAction func btnRegisterClicked(_ sender: Any) {
        onRegister?()
    }
}
