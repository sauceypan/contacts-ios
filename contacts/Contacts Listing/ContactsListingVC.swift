//
//  ContactsListingVC.swift
//  contacts
//
//  Created by Patrick Ngo on 2018-06-19.
//  Copyright © 2018 Patrick Ngo. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ContactListingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var contactList: [ContactModel] = []
    var contactListWithSections = [[ContactModel]]()

    
    //MARK: - Views -
    
    private var refreshControl:UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        return rc
    }()
    
    private lazy var tableView : UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.accessibilityLabel = "contacts_collectionview"
        tv.separatorStyle = .singleLine
        tv.sectionIndexColor = UIColor.Text.lightGrey
        tv.separatorColor = UIColor.Border.line
        tv.delegate = self
        tv.dataSource = self
        tv.addSubview(self.refreshControl)
        
        //cell registration
        tv.register(ContactsListingCell.self, forCellReuseIdentifier: String(describing: ContactsListingCell.self))
        return tv
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
    
    func setupNavBar() {
        UIApplication.shared.statusBarStyle = .lightContent

        // Customize navigation bar
        self.navigationItem.title = "Contacts"
        self.navigationController?.navigationBar.tintColor = UIColor.Text.green
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.Text.darkGrey]
        
        // Remove bottom line/shadow
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    func setupNavBarButtons() {
        // Add Groups and + buttons
        let groupsBtn = UIBarButtonItem(title: "Groups", style: .plain, target: self, action: #selector(onPressGroups))
        let addBtn = UIBarButtonItem(title: "＋", style: .plain, target: self, action: #selector(onPressAdd))
        self.navigationItem.leftBarButtonItem = groupsBtn
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    func setupViews() {
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
    }
    
    func loadData(reloadAll:Bool = false) {
        ContactsAPI.fetchContacts { (result, error) in
            if let result = result, error == nil {
                do {
                    let contactsResponse = try JSONDecoder().decode([ContactModel].self, from: result)
                    
                    //set list of contacts
                    self.contactList = contactsResponse
                    self.contactListWithSections = collation.partitionObjects(array: self.contactList)
                    
                    //reload table
                    self.tableView.reloadData()
                }
                catch {
                    print("Error serializing json:", error)
                }
            }
            // stop refresh control
            if (self.refreshControl.isRefreshing) {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func reloadData(refreshControl: UIRefreshControl) {
        self.loadData(reloadAll:true)
    }
    
    //MARK: - On Press handlers -
    
    @objc func onPressGroups() {
        // TODO: go to groups screen
    }
    
    @objc func onPressAdd() {
        // Go to contact add screen
        let contactEditVC = ContactEditVC()
        let contactEditNavController = UINavigationController(rootViewController: contactEditVC)
        self.present(contactEditNavController, animated: true)
    }
    
    //MARK: - TableView Datasource -

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactListWithSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.contactListWithSections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collation.sectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return UILocalizedIndexedCollation.current().sectionTitles
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactCell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: ContactsListingCell.self)) as? ContactsListingCell
        
        //set contact
        contactCell?.contact = self.contactListWithSections[indexPath.section][indexPath.row]
        
        return contactCell!
    }
    
    
    //MARK: - TableView Delegate -
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactListWithSections[indexPath.section][indexPath.row]
        
        // Go to contact detail screen
        let contactDetailVC = ContactDetailVC()
        contactDetailVC.contactId = contact.id
        self.navigationController?.pushViewController(contactDetailVC, animated: true)
    }
    
    
}
