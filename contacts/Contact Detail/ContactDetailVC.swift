//
//  ContactDetailVC.swift
//  contacts
//
//  Created by Patrick Ngo on 2018-06-19.
//  Copyright © 2018 Patrick Ngo. All rights reserved.
//

import UIKit

class ContactDetailVC: UIViewController, ContactDetailActionPanelDelegate, ContactEditDelegate {
    
    var contactId: Int? = nil
    var contact: ContactModel? = nil {
        didSet {
            //first name
            if let firstName = contact?.first_name {
                self.nameLabel.text = firstName
                
                // last name
                if let lastName = contact?.last_name {
                    self.nameLabel.text = "\(firstName) \(lastName)"
                }
            }
            // profile photo
            if let profilePic = contact?.profile_pic {
  
                if profilePic == ContactsAPI.DEFAULT_IMG {
                    self.profilePhotoImageView.sd_setImage(with: URL(string: ContactsAPI.DEFAULT_IMG_URL))
                } else {
                    self.profilePhotoImageView.sd_setImage(with: URL(string: profilePic))
                }
            }
            // mobile
            if let mobile = contact?.phone_number {
                self.mobileRow.textField.text = mobile
            }
            // email
            if let email = contact?.email {
                self.emailRow.textField.text = email
            }
            // favourite
            if let favourite = contact?.favorite {
                self.actionPanel.favourited = favourite
            }
        }
    }
    
    //MARK: - Views -
    
    lazy var actionPanel: ContactDetailActionPanel = {
        let ap = ContactDetailActionPanel()
        ap.delegate = self
        return ap
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
    
    let profilePhotoImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60 //size 120
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3
        iv.backgroundColor = UIColor.white
        return iv
    }()
    
    let nameLabel:UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        lbl.textColor = UIColor.Text.darkGrey
        return lbl
    }()
    
    let emailRow: ContactDetailLabelRow = {
        let tf = ContactDetailLabelRow(frame: CGRect.zero)
        tf.nameLabel.text = "Email"
        return tf
    }()
    
    let mobileRow: ContactDetailLabelRow = {
        let tf = ContactDetailLabelRow(frame: CGRect.zero)
        tf.nameLabel.text = "Mobile"
        return tf
    }()
    
    //MARK: - Init -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupNavBarButtons()
        self.setupViews()
        
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupNavBar()
    }
    
    func setupViews() {
        let containerView = UIView()
        self.view.addSubview(containerView)
        containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.backgroundImageView)
        self.scrollView.addSubview(self.mobileRow)
        self.scrollView.addSubview(self.emailRow)
        self.backgroundImageView.addSubview(self.profilePhotoImageView)
        self.backgroundImageView.addSubview(self.nameLabel)
        self.backgroundImageView.addSubview(self.actionPanel)
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(0)
        }
        self.scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(0)
        }
        self.backgroundImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(containerView.snp.top)
            make.bottom.equalTo(self.scrollView.snp.top).offset(300)
        }
        self.profilePhotoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.scrollView.snp.top).offset(20)
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.height.equalTo(120)
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.profilePhotoImageView.snp.bottom).offset(10)
            make.centerX.equalTo(self.profilePhotoImageView.snp.centerX)
        }
        self.actionPanel.snp.makeConstraints { (make) in
            make.left.equalTo(44)
            make.right.equalTo(-44)
            make.height.equalTo(70)
            make.bottom.equalTo(self.backgroundImageView.snp.bottom).offset(-15)
        }
        self.mobileRow.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.backgroundImageView.snp.bottom)
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
        // remove bottom line/shadow and make clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func setupNavBarButtons() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        let editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onPressEdit))
        
        navigationItem.rightBarButtonItem = editBtn
    }
    
    func loadData() {
        guard let contactId = self.contactId else { return }

        ContactsAPI.fetchContact(id: contactId) { (result, error) in
            if let result = result, error == nil {
                do {
                    let contactResponse = try JSONDecoder().decode(ContactModel.self, from: result)
                    
                    // Set contact
                    self.contact = contactResponse
                }
                catch {
                    let alert = UIAlertController(title: "Error", message: "Error fetching contact.", preferredStyle: .alert)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    //MARK: - On Press handlers -
    
    @objc func onPressEdit() {
        // Go to contact edit screen
        let contactEditVC = ContactEditVC()
        contactEditVC.contact = self.contact
        contactEditVC.delegate = self

        let contactEditNavController = UINavigationController(rootViewController: contactEditVC)
        self.present(contactEditNavController, animated: true)
    }
    
    //MARK: - ContactEditDelegate -
    
    func contactUpdated(contact: ContactModel) {
        self.contactId = contact.id
        self.contact = contact
    }
}
