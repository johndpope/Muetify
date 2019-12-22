//
//  ContactsTableViewController.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/13/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import UIKit
import Contacts
import PhoneNumberKit

class ContactsTableViewController: UITableViewController {
    
    var token: String!
    
    var items: [Item] = []
    
//    func uploadContacts(phoneNumbers: [String]) {
//        AppService().setToken(token: token).addContacts(phoneNumbers: phoneNumbers) { [weak self] phoneNumbers, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.showMessage(title: "Error", message: error.localizedDescription)
//                    self?.refreshControl?.endRefreshing()
//                } else {
//                    self?.loadContacts()
//                }
//            }
//        }
//    }
    
//    func processContacts(contacts: [CNContact]) {
//        let phoneNumberKit = PhoneNumberKit()
//        var phoneNumbers: [String] = []
//
//        for contact in contacts {
//            if !contact.phoneNumbers.isEmpty {
//                for phoneNumber in contact.phoneNumbers {
//                    let phoneNumberStruct = phoneNumber.value as CNPhoneNumber
//                    let phoneNumberString = phoneNumberStruct.stringValue
//                    if let number = try? phoneNumberKit.parse(phoneNumberString) {
//                        phoneNumbers.append(phoneNumberKit.format(number, toType: .e164))
//                    }
//                }
//            }
//        }
//
//        uploadContacts(phoneNumbers: phoneNumbers)
//    }
    
//    func fetchContacts() {
//        refreshControl?.beginRefreshing()
//        DispatchQueue.main.async { [weak self] in
//            let contactStore = CNContactStore()
//
//            let keysToFetch = [CNContactPhoneNumbersKey]
//
//            var allContainers: [CNContainer] = []
//
//            do {
//                allContainers = try contactStore.containers(matching: nil)
//            } catch {
//                print("Error fetching containers")
//            }
//
//            var results: [CNContact] = []
//
//            for container in allContainers {
//                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
//                do {
//                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
//                    results.append(contentsOf: containerResults)
//                } catch {
//                    print("Error fetching results for container")
//                }
//            }
//
//            self?.processContacts(contacts: results)
//        }
//    }
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func initContacts(contacts: [UserData]) {
        items.removeAll()
        items.append(Header(title: "Мои контакты", description: nil))
        for contact in contacts {
            items.append(Contact(
                id: contact.pk,
                firstName: contact.firstName,
                lastName: contact.lastName,
                phoneNumber: contact.phoneNumber,
                avatar: contact.avatar
            ))
        }
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func loadContacts() {
        AppService().setToken(token: token).getContacts { [weak self] contacts, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showMessage(title: "Error", message: error.localizedDescription)
                    self?.refreshControl?.endRefreshing()
                } else {
                    self?.initContacts(contacts: contacts)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "token")
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl!)
        
//        DispatchQueue.main.async(execute: fetchContacts)
        loadContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        var cell: UITableViewCell?
        
        switch item {
        case is Header:
            cell = tableView.dequeueReusableCell(withIdentifier: "items_header", for: indexPath)
        case is Contact:
            let contact = item as! Contact
            let itemView = tableView.dequeueReusableCell(withIdentifier: "items_contact", for: indexPath) as? ItemsContactTableViewCell
            
            itemView?.fullNameLabel.text = "\(contact.firstName) \(contact.lastName)"
            itemView?.phoneNumberLabel.text = contact.phoneNumber
            
            if let urlString = contact.avatar, let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    if let data = try? Data(contentsOf: url) {
                        itemView?.avatarImageView.image = UIImage(data: data)
                    } else {
                        itemView?.avatarImageView.image = nil
                    }
                }
            } else {
                itemView?.avatarImageView.image = nil
            }
            
            cell = itemView
        default:
            cell = nil
        }
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileTableViewController = segue.destination as? ProfileTableViewController,
            let indexPath = tableView.indexPathForSelectedRow,
            let contact = items[indexPath.row] as? Contact {
            profileTableViewController.friend = contact
        }
    }

    @objc func refresh(sender:AnyObject) {
        loadContacts()
    }
    
}




