//
//  RegisterViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 07.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable redundant_discardable_let

import UIKit
import RxSwift
import RxCocoa

@objc(RegisterViewController)
class RegisterViewController: UIViewController {
    @IBOutlet weak var lblErrorMessage: UILabel! {
        didSet {
            lblErrorMessage.layer.cornerRadius = 10
            lblErrorMessage.layer.borderWidth = 1
            lblErrorMessage.layer.borderColor = UIColor.systemRed.cgColor
            lblErrorMessage.isHidden = true
            lblErrorMessage.text = ""
        }
    }
    
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnRegister: UIButton! {
        didSet {
            btnRegister.isEnabled = false
        }
    }
    
    let service = UserService.shared
    var onRegistrationDone: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // А на этом экране навигация пригодится
        navigationController?.navigationBar.isHidden = false
        title = "Регистрация"
        
        // Убираем клавиатуру по клику на форму
        let touchGuesture = UITapGestureRecognizer(target: self, action: #selector(onViewClick))
        self.view.addGestureRecognizer(touchGuesture)
        
        // При првильно заполненых полях кнопка "Зарегистрироваться" становится активной
        configureBtnRegisterClicked()
    }
    
    private func configureBtnRegisterClicked() {
        let _ = Observable.combineLatest(txtLogin.rx.text, txtName.rx.text, txtEmail.rx.text,
                                         txtPassword.rx.text, txtNewPassword.rx.text).map { (login, name, email, password, newPassword) in
                                            return (!(login ?? "").isEmpty && !(name ?? "").isEmpty && !(email ?? "").isEmpty &&
                                                    !(password ?? "").isEmpty && !(newPassword ?? "").isEmpty && password == newPassword)
        }.bind { [weak btnRegister] fieldFillCorrect in
            btnRegister?.isEnabled = fieldFillCorrect
        }
    }
    
    @objc
    private func onViewClick() {
        self.view.endEditing(true)
    }
    
    private func showFormError(message: String) {
        lblErrorMessage.layer.opacity = 0
        lblErrorMessage.isHidden = false
        lblErrorMessage.text = message
        
        UIView.animate(withDuration: 2, animations: {
            self.lblErrorMessage.layer.opacity = 1
        }, completion: { _ in
            UIView.animate(withDuration: 5) {
                self.lblErrorMessage.layer.opacity = 0
            }
        })
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        // Проверим все необходимые данные
        guard let login = txtLogin.text, login.isEmpty == false,
            let password = txtPassword.text, password.isEmpty == false,
            let newPassword = txtNewPassword.text, newPassword.isEmpty == false,
            let email = txtEmail.text, email.isEmpty == false,
            let name = txtName.text, name.isEmpty == false else {
                showFormError(message: "Все поля формы обязательны")
                return
        }
        
        // также проверим совпадают ли пароли
        guard password == newPassword else {
            showFormError(message: "Пароли не совпадают")
            return
        }
        
        // Регистрируем пользователя
        do {
            try service.register(user: User(login: login, password: password, email: email, name: name))
            
            // Пользователь найден - поставим флаг
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            // Если мы всё еще здесь, значит все прошло удачно
            onRegistrationDone?()
            
        } catch let error {
            if let error = error as? RegisterError {
                switch error {
                case .userFound:
                    showFormError(message: "Такой пользовтаель уже есть")
                default:
                    showFormError(message: "Ошибка регистрации пользователя")
                }
                
            } else {                
                showFormError(message: "Ошибка регистрации пользователя")
            }
        }
    }
    
}
