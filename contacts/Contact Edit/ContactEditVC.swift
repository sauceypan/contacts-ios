//
//  ContactEditVC.swift
//  contacts
//
//  Created by Patrick Ngo on 2018-06-21.
//  Copyright © 2018 Patrick Ngo. All rights reserved.
//

import UIKit

protocol ContactEditDelegate:class {
    func contactUpdated(contact: ContactModel)
}

class ContactEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate:ContactEditDelegate? = nil
    
    var contactId: Int? = nil
    var contact: ContactModel? = nil {
        didSet {
            // profile photo
            if let profilePic = contact?.profile_pic {
                
                if profilePic != ContactsAPI.DEFAULT_IMG {
                    self.profilePhotoImageView.sd_setImage(with: URL(string: profilePic))
                }
            }
            // first name
            if let firstName = contact?.first_name {
                self.firstNameRow.textField.text = firstName
            }
            // last name
            if let lastName = contact?.last_name {
                self.lastNameRow.textField.text = lastName
            }
            // mobile
            if let mobile = contact?.phone_number {
                self.mobileRow.textField.text = mobile
            }
            // email
            if let email = contact?.email {
                self.emailRow.textField.text = email
            }
        }
    }
    
    //MARK: - Views -
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor =  UIColor.Background.lightGrey
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    let backgroundImageView: UIView = {
        let iv = UIView()
        iv.backgroundColor =  .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.addGreenGradient()
        return iv
    }()
    
    let profilePhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "placeholder_photo")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60 //size 120
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3
        iv.backgroundColor = UIColor.white
        return iv
    }()
    
    let cameraButton: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "camera_button"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(onPressCamera), for: .touchUpInside)
        return btn
    }()
    
    let firstNameRow: ContactEditRow = {
        let tf = ContactEditRow(frame: CGRect.zero)
        tf.nameLabel.text = "First Name"
        return tf
    }()
    
    let lastNameRow: ContactEditRow = {
        let tf = ContactEditRow(frame: CGRect.zero)
        tf.nameLabel.text = "Last Name"
        return tf
    }()
    
    let emailRow: ContactEditRow = {
        let tf = ContactEditRow(frame: CGRect.zero)
        tf.nameLabel.text = "Email"
        return tf
    }()
    
    let mobileRow: ContactEditRow = {
        let tf = ContactEditRow(frame: CGRect.zero)
        tf.nameLabel.text = "Mobile"
        return tf
    }()
    
    //MARK: - Init -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //keyboard notifications
        self.registerKeyBoardNotifications()
        
        self.setupNavBar()
        self.addNavbarButtons()
        self.setupViews()
    }
    
    func setupViews() {
        self.view.addSubview(self.containerView)
        self.containerView.addSubview(self.scrollView)
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 440)
        
        self.scrollView.addSubview(self.backgroundImageView)
        self.backgroundImageView.addSubview(self.profilePhotoImageView)
        self.backgroundImageView.addSubview(self.cameraButton)
        
        self.scrollView.addSubview(self.firstNameRow)
        self.scrollView.addSubview(self.lastNameRow)
        self.scrollView.addSubview(self.mobileRow)
        self.scrollView.addSubview(self.emailRow)
        
        self.containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(0)
        }
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView.snp.bottom).offset(0)
        }
        self.backgroundImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(containerView.snp.top)
            make.bottom.equalTo(self.scrollView.snp.top).offset(180)
        }
        self.profilePhotoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.scrollView.snp.top).offset(20)
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.height.equalTo(120)
        }
        self.cameraButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.profilePhotoImageView.snp.centerX).offset(20)
            make.bottom.equalTo(self.profilePhotoImageView.snp.bottom)
            make.width.height.equalTo(42)
        }
        self.firstNameRow.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.backgroundImageView.snp.bottom)
            make.height.equalTo(60)
        }
        self.lastNameRow.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.firstNameRow.snp.bottom)
            make.height.equalTo(60)
        }
        self.mobileRow.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.lastNameRow.snp.bottom)
            make.height.equalTo(60)
        }
        self.emailRow.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.mobileRow.snp.bottom)
            make.height.equalTo(60)
        }
    }
    
    func setupNavBar() {
        // Customize navigation bar
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.Text.green
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.Text.darkGrey]
        
        // remove bottom line/shadow and make clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    func addNavbarButtons() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onPressCancel))
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onPressDone))
        navigationItem.leftBarButtonItem = cancelBtn
        navigationItem.rightBarButtonItem = doneBtn
    }
    
    //MARK: - On Press handlers -
    
    @objc func onPressDone() {
        //TODO: save to api
        
        let firstName = self.firstNameRow.textField.text!
        let lastName = self.lastNameRow.textField.text!
        let mobile = self.mobileRow.textField.text!
        let email = self.emailRow.textField.text!
        
        let contactParams = [
            "first_name": firstName,
            "last_name": lastName,
            "phone_number": mobile,
            "email": email
        ]
        
        // Updating a contact
        if let contact = self.contact {
            ContactsAPI.updateContact(id: contact.id!, contactParams: contactParams) { (result, error) in
                if let result = result, error == nil {
                    do {
                        let contactResponse = try JSONDecoder().decode(ContactModel.self, from: result)
                        
                        // Notify delegate
                        if let delegate = self.delegate {
                            delegate.contactUpdated(contact: contactResponse)
                        }
                        // TODO: refresh the list of contacts
                        self.dismiss(animated: true)
                    }
                    catch {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        self.present(alert, animated: true)
                    }
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        // Creating a contact
        else {
            ContactsAPI.createContact(contactParams: contactParams) { (result, error) in
                if let result = result, error == nil {
                    do {
                        let _ = try JSONDecoder().decode(ContactModel.self, from: result)
                        // TODO: refresh the list of contacts
                        self.dismiss(animated: true)
                    }
                    catch {
                        let alert = UIAlertController(title: "Error", message: "Error creating contact.", preferredStyle: .alert)
                        self.present(alert, animated: true)
                    }
                }
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc func onPressCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func onPressCancel() {
        self.dismiss(animated: true)
    }
    
    //MARK: - UIImagePickerControllerDelegate / UINavigationControllerDelegate -

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profilePhotoImageView.image = chosenImage
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    

    //MARK: - Keyboard notifications -
    
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(0).offset(-keyboardSize.size.height)
            })
        }
        if let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber) {
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        self.scrollView.snp.updateConstraints({ (make) in
            make.bottom.equalTo(0)
        })
        if let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber) {
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}
