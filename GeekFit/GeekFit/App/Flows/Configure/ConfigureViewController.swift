//
//  ConfigureViewController.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 26.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
// swiftlint:disable colon

import UIKit

@objc(ConfigureViewController)
class ConfigureViewController: UIViewController {
    @IBOutlet weak var imgAvatarView: UIImageView! {
        didSet {
            imgAvatarView.image = UIImage(named: "default_picker")
        }
    }
    
    @IBOutlet weak var btnAddAvatar: UIButton! {
        didSet {
            btnAddAvatar.isEnabled = false
        }
    }
    
    // Проверим можно ли добавить аватар
    let isCameraAvaileble = UIImagePickerController.isSourceTypeAvailable(.camera)
    let isPhotoLibraryAvaileble = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    
    var didAvatarChanged: ((UIImage?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Настройки"
        
        // Если доступ к камере или библиотке фото есть - покажем кнопку
        if isCameraAvaileble || isPhotoLibraryAvaileble {
            btnAddAvatar.isEnabled = true
        }
        
        // Попробуем загрузить ранее сохраненную аватарку
        if let defaultAvatar = AppManager.shared.loadAvatarFromDisk() {
            imgAvatarView.image = defaultAvatar
        }
        
    }
    
    @IBAction func btnAvatarChangeClicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        
        // Приоритет у нас над камерой, но если она не доступна - то позволим выбрать аватарку из альбома
        imagePicker.sourceType = isCameraAvaileble ? .camera : .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }

}

extension ConfigureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        } else {
            image = nil
        }
        
        if let image = image,
           let smallImage = AppManager.shared.resizeAvatar(image) {
            imgAvatarView.image = smallImage
            
            // Сохраним аватар
            AppManager.shared.saveAvatarToDisk(avatar: smallImage)
            
            // Выполним замыкание с новым аватаром
            didAvatarChanged?(smallImage)
        }
        
        // Закроем окно
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
