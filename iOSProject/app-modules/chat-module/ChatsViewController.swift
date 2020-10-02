//
//  ChatsViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/29/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import Foundation

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController {

    @IBOutlet weak var chatsTableView: UITableView!
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Chat ...."
        search.searchBar.sizeToFit()
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.barTintColor = .white
        search.searchBar.set(textColor: .white)
        search.searchBar.setTextField(color: .white)
        search.searchBar.setPlaceholder(textColor: .black)

        return search
    }()

    var userAuth: User?
    
    var chatsNoRead:[String] = []
    
    private var chats: [Chat] = [] {
        didSet{
            
            guard let userAuth = self.userAuth else {
                return
            }
            
            usersChats.removeAll()
            
            for chat in chats {
                
                let guestID = chat.users.filter{ $0 != userAuth.document?.documentID }.first!
                UserAPI.shared.get(documentID: guestID) { result in
                   switch result {
                   case .success(let document):
                        var userGuest = User(dictionary: document.data()!)!
                        userGuest.document = document.reference
                        var updatedChat = chat
                        updatedChat.userGuest = userGuest
                        self.usersChats.append(updatedChat)
                   case .failure(let error):
                       print(error)
                   }
                }
            }
        }
    }
    
    private var usersChats : [Chat] = [] {
        didSet{
            self.chatsTableView.reloadData()
        }
    }
    
    private var filteredChats = [Chat]()
    
    private var listener: ListenerRegistration?

    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
       
    fileprivate func observeQuery() {
      guard let query = query else { return }
      stopObserving()

      listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
        guard let snapshot = snapshot else {
          print("Error fetching snapshot results: \(error!)")
          return
        }
        let models = snapshot.documents.map { (document) -> Chat in
            if let model = Chat(dictionary: document.data()) {
            return model
          } else {
            // Don't use fatalError here in a real app.
            fatalError("Unable to initialize type \(Chat.self) with dictionary \(document.data())")
          }
        }
        
        
        self.chats = models
        }
    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("chats").whereField("users", arrayContains: userAuth?.document?.documentID ?? "Not Found User 1")
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        observeQuery()
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
       
    func setup() {
        
        title = "Chats"
        
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
    
        if let userAuth = AuthenticationManager.shared.currentUser {
            self.userAuth = userAuth
        }
        
        query = baseQuery()

        navigationItem.searchController = searchController
    }

    deinit {
        listener?.remove()
    }
    
    func filterContentForSearchText(searchText: String){
        
        filteredChats = usersChats.filter { (chat: Chat) -> Bool in
            if isSearchBarEmpty() {
                return true
            }else{
                return (chat.userGuest?.first.lowercased().contains(searchText.lowercased()))! || (chat.userGuest?.last.lowercased().contains(searchText.lowercased()))!
            }
        }
        
        chatsTableView.reloadData()
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
    
}

extension ChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chat: Chat
        
        if isFiltering() {
            chat = filteredChats[indexPath.row]
        }else {
            chat = usersChats[indexPath.row]
        }
        
        let destinationVC = ChatViewController()
        
        if let userGuest = chat.userGuest {
        AuthenticationManager.shared.currentUser?.document?.collection("chats").document(userGuest.document!.documentID).updateData([
                "count": 0
            ])
            
            chatsNoRead = chatsNoRead.filter { $0 != userGuest.document!.documentID }
            
            destinationVC.user2Name = "\(userGuest.first) \(userGuest.last)"
            destinationVC.user2UID = userGuest.document?.documentID
            destinationVC.user2ImgUrl = userGuest.imagePath
            destinationVC.user2FcmToken = userGuest.fcmToken
        }
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}

extension ChatsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() { return filteredChats.count }
        return usersChats.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatViewCell", for: indexPath) as! ChatViewCell
        
        let chat: Chat
        
        if isFiltering() {
            chat = filteredChats[indexPath.row]
        }else {
            chat = usersChats[indexPath.row]
        }
        
        let isNoRead = chatsNoRead.contains(chat.userGuest!.document!.documentID)
        cell.setup(chat: chat, isNoRead: isNoRead)
        return cell
        
    }
    
}

extension ChatsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchText: searchBar.text!)
    }
   
}
