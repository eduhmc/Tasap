//
//  ChatViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 5/28/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore

class ChatViewController: MessagesViewController {

    private var docReference: DocumentReference?
    var messages: [Message] = []
    //I've fetched the profile of user 2 in previous class from which //I'm navigating to chat view. So make sure you have the following //three variables information when you are on this class.
    var user2Name: String?
    var user2ImgUrl: String?
    var user2UID: String?
    var user2FcmToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.title = user2Name ?? "Chat"
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = UIColor(hexString: "#007B98")
        messageInputBar.sendButton.setTitleColor(UIColor(hexString: "#007B98"), for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        loadChat()
    }
    

    func loadChat() {
        
        guard let userAuth = AuthenticationManager.shared.currentUser else {
            return
        }
    
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("chats").whereField("users", arrayContains: userAuth.document?.documentID ?? "Not Found User 1")
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                if queryCount == 0 {
                    //If documents count is zero that means there is no chat available and we need to create a new instance
                    self.createNewChat()
                }
                else if queryCount >= 1 {
                    //Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        let chat = Chat(dictionary: doc.data())
                        //Get the chat which has user2 id
                        if (chat?.users.contains(self.user2UID!))! {
                            self.docReference = doc.reference
                            //fetch it's thread collection
                            doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        self.messages.removeAll()
                                        for message in threadQuery!.documents {
                                            let msg = Message(dictionary: message.data())
                                            self.messages.append(msg!)
                                            print("Data: \(msg?.content ?? "No message found")")
                                        }
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToBottom(animated: true)
                                    }
                                })
                            return
                        } //end of if
                    } //end of for
                    self.createNewChat()
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
    func createNewChat() {
    
        guard let userAuth = AuthenticationManager.shared.currentUser else {
            return
        }
        
        let users = [userAuth.document?.documentID, self.user2UID]
        let data: [String: Any] = [
            "users":users
        ]
        let db = Firestore.firestore().collection("chats")
        db.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    private func insertNewMessage(_ message: Message) {
    
        //add the message to the messages array and reload it
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    private func save(_ message: Message) {
        
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName
        ]
        
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            
            self.messagesCollectionView.scrollToBottom()
            
            guard let userAuth = AuthenticationManager.shared.currentUser else {
                return
            }
            
            let sender = PushNotificationAPI()
            sender.sendPushNotification(to: self.user2FcmToken! , title: "\(userAuth.first) \(userAuth.last)" , body: message.content)
            
        Firestore.firestore().collection("users").document(self.user2UID!).collection("chats").document(userAuth.document!.documentID).setData(["count": 1], merge: true)

        })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
        guard let userAuth = AuthenticationManager.shared.currentUser else {
            return
        }
        
        //When use press send button this method is called.
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: userAuth.document!.documentID, senderName: userAuth.first)
        //calling function to insert and save message
        insertNewMessage(message)
        save(message)
        //clearing input field
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate, MessagesDataSource {
    
    //This method return the current sender ID and name
    func currentSender() -> SenderType {
        let userAuth = AuthenticationManager.shared.currentUser!
        return Sender(id: userAuth.document!.documentID, displayName: userAuth.first)
    }
    
    //This return the MessageType which we have defined to be text in Messages.swift
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    //Return the total number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
 
}

extension ChatViewController: MessagesLayoutDelegate {
    
    //We want the default avatar size. This method handles the size of the avatar of user that'll be displayed with message
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    //Explore this delegate to see more functions that you can implement but for the purpose of this tutorial I've just implemented one function.
    
}

extension ChatViewController: MessagesDisplayDelegate {
    
    //Background colors of the bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(hexString: "#007B98") : .lightGray
    }
    
    //THis function shows the avatar
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    
        guard let userAuth = AuthenticationManager.shared.currentUser else {
            return
        }
        
        //If it's current user show current user photo.
        if message.sender.senderId == userAuth.document?.documentID {
            avatarView.kf.setImage(with: URL(string: userAuth.imagePath))
        } else {
            avatarView.kf.setImage(with: URL(string: user2ImgUrl!))
        }
    }
    
    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
}
