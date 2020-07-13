//
//  HomeViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/2/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    
    public var user: User?
    
    private var sortedFirstLetters: [String] = []
    private var sections: [[Career]] = [[]]
    
    private var careers: [Career] = [] {
        didSet {
            
            //DEMO IMPORT DATA
        
            /*let docRef = Firestore.firestore().collection("countries").document("WeOjxiRK8NPXDl94joEn").collection("universities").document("hB3H9rQtRBTpFNZHgOzH")
            
            let array = ["0aN0DVmbf0q9Ac7ghpA5",
            "18D3wffdXTbNNP96hwIx",
            "1afdKWoBMpZTVdCuPOJQ",
            "1ci8FI9e7M1BUUcmaBWX",
            "2rVMDxCP1g2MLH9ZbeMA",
            "3OC4fhc2ukeIrGScVvhT",
            "4bli13h2E2CbWxIPqoUw",
            "4dsEswcLdj1FR5xmXXUj",
            "4osfupHPkiA0NOw1wN5K",
            "4veGYViFQZCxJ5oftela",
            "5Pi9LIBT1dCKleneESbf",
            "5qV9HLT12pKlWRkJ1SBT",
            "5uPEqKwnXQuq0OzazIxL",
            "6EVLSgJSuGqAk67Jp5K5",
            "6ej2zXLbyZazCix2of9o",
            "6uw8Dg4aoJL3btCmp3uj",
            "6vGY3mFanBJKkzyyhcr5",
            "6vgVfEpWAAfUGcHOOB7l",
            "6vwV4tfO0STSvOyrBcsi",
            "6xkBDs07jyk4r0PZ7qi1",
            "79CvvGQzqFlUTbeexGGz",
            "7BDFqGNwOgNrx1rylC6u",
            "7GcUUbnIZnJmMVdOc9Ng",
            "7XJLe79NEObqYghck5xu",
            "7YYVah887tCGIERk8Erl",
            "8bRaeED93CvFEWlgM0b4",
            "A4v1FMb3ZnhcsRBZIimc",
            "A9EdSh9kDgbzdoQkIyFS",
            "Aaoi30sdTwjiDrQgTSxM",
            "Ag4PogQ3z0KrzFauqVTw",
            "Amqs3pLYIAQksPxVma8l",
            "AwcdtnM6yLuVKE2UYYmt",
            "BD1VOkipNZzqry6VVKfr",
            "BeR5CfKugrLKZHQ93YM4",
            "CPiFd6vzYLGUXk6haJDP",
            "CooqmwSI8IHKIgpDYumX",
            "DPPRIMu04leNs3rXiXlV",
            "EKrXDzVDnTRYt3TrBorO",
            "F55f4tPx0oM2FFdk9WXt",
            "FDZ3CnctTCHbLsAmSiOz",
            "FPcYNpnuNpQJhI9tRwz4",
            "FfEukPDkocWz9RRUHao3",
            "FphpfYVbURe0RbpdCm5L",
            "FsGBWxgGDIShE6ZhePys",
            "G0MqetaXHd4lbEwPpeES",
            "GlipjGwIJ1oWf0SzyVZO",
            "H57LR64Bkok0kfzNCWMr",
            "HHFHA7SOUWuIJMCM2lWO",
            "HYSdXq9HhK1XMBc3sbxO",
            "HbGWUPLp32tCa9ak0HeF",
            "HlXIem2OM7pgmBOfHDxZ",
            "I6LF2mVNtx8ZPtEtCjZW",
            "I6oUseNGNJS4mlRV82IL",
            "IBQ2RS4SRtmhpcQjhJVs",
            "INVHR0vnfnV4PwGwVWpE",
            "IOPC6A5gdjWuSs3CU5HK",
            "IqWhghMYOURk86GRKJYe",
            "IzMwAKGNHVnCAEPfQOw5",
            "JKtu4e4tGDg1DtAlL4gH",
            "JQsm1AJy5S8lhJXKtQmP",
            "Jn6NxsWsGWTy59Hoo5e9",
            "K1WDXJ5fN75XFSZ4aKtT",
            "KC0Xsl9ggq9oXnAKngGb",
            "KS8v0EXmwYj6UmbA4IyP",
            "KjH2gmy9xyLd8oFevboN",
            "Krtt1uIjEEHSbmLQwVyn",
            "L00exFUJULfs7JzdmAsb",
            "LkaaOsClmYtqbfDCqm4v",
            "M2Rn93METpmbFKwleuvM",
            "M2SUXdOqcLTYFfDgceGM",
            "MKa4wsxdw9zqWdLLrm69",
            "MbVtclSCZQblVCEUiqqH",
            "MvAt9a1amVhC7RAS2lLS",
            "NV3frdjJZ0Svp2GrNvG6",
            "O6U9NuEYlr5OqzSSxI65",
            "OWhB1UZ7tKNnjw5YyrBp",
            "Ooc795X85ffpny817noR",
            "Oz3olq58Pushi2zf7WX0",
            "P0lP2uuMfDcw2ASInPHe",
            "P6jzGCo3H3JXUfJXbdU3",
            "Ps9fFqHGQrjRL4tUvXpd",
            "Q47rIxranE9pE7ooNcpW",
            "Q7XvaJ6usALD4Mx69D7r",
            "QGjVv0t7neJQ2uP8ohf1",
            "R4guHvXTt5Cr9gQxZL2x",
            "RlmZGVjSVvjhaU7DYFkt",
            "RomekIZmtgHPoCdOon6M"]

            for career in careers {

               // docRef.collection("careers").document(career.document!.documentID).setData(career.dictionary)
            
                if !array.contains(career.document!.documentID){
                    
                    career.document?.reference.collection("courses").getDocuments() { (querySnapshot, err) in
                    
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                           
                            for document in querySnapshot!.documents {
                                docRef.collection("careers").document(career.document!.documentID).collection("courses").document(document.documentID).setData(document.data())
                            }
                        }
                    
                    }
                    
                }

            }*/
            
            
            let firstLetters = careers.map { $0.nameFirstLetter }
            let uniqueFirstLetters = Array(Set(firstLetters))
            
            sortedFirstLetters = uniqueFirstLetters.sorted()
            sections = sortedFirstLetters.map { firstLetter in
                return careers
                    .filter { $0.nameFirstLetter == firstLetter }
                    .sorted { $0.name < $1.name }
            }
            
            self.homeTableView.reloadData()
        }
    }

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
         let models = snapshot.documents.map { (document) -> Career in
           if var model = Career(dictionary: document.data()) {
             model.document = document
             return model
           } else {
             // Don't use fatalError here in a real app.
             fatalError("Unable to initialize type \(Career.self) with dictionary \(document.data())")
           }
         }
         self.careers = models
       }

    }

    fileprivate func stopObserving() {
        listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        
        if let user = self.user, user.university.count > 1 {
            return Firestore.firestore().collection("countries").document(user.country).collection("universities").document(user.university).collection("careers")
        }
        
        return Firestore.firestore().collection("careers")
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
        homeTableView.delegate = self
        homeTableView.dataSource = self
 
        query = baseQuery()
    }

    deinit {
      listener?.remove()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = sender as! IndexPath
        let career = sections[indexPath.section][indexPath.row]
        let destinationVC = segue.destination as! HomeDetailViewController
        destinationVC.career = career
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      performSegue(withIdentifier: "homeDetailSegue", sender: indexPath)
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedFirstLetters[section]
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedFirstLetters
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedFirstLetters.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell",
                                                 for: indexPath) as! HomeTableViewCell
        let career = sections[indexPath.section][indexPath.row]
        cell.populate(career: career)
        return cell
        
    }
    
}

