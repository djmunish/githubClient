//
//  PullRequestVC.swift
//  gitTest
//
//  Created by Ankur Sehdev on 06/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit

class PullRequestVC: UIViewController {
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var pullRequest: [PullRequestResponse] = []
    var branch:BranchResponse!
    var accessToken:String!
    var repo:RepositoryResponse!

    @IBOutlet weak var activityLoader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPullRequests()
        // Do any additional setup after loading the view.
    }
   
    func fetchPullRequests(){
        GithubLoginAPI().getPullRequests(accesstoken: accessToken, ownerName: repo.owner?.login ?? "", repoName: repo.name ?? "", branch: branch.name ?? "") { (response, err) in
            self.pullRequest = response ?? []
            DispatchQueue.main.async {
                self.activityLoader.stopAnimating()
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PullRequestVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pullRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PullRequestCell") as! PullRequestCell
        let pullReq = self.pullRequest[indexPath.row]
        cell.prLbl.text = pullReq.title
        
        let body = pullReq.body ?? "" == "" ? "NA" : pullReq.body ?? ""
        
        cell.numberLbl.text = "#\(String(describing: pullReq.number!))"
        cell.bodyLbl.text = "Description: \(body)"
        cell.statusLbl.text = "Status: \(pullReq.state ?? "")"
//        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let branch = self.branches[indexPath.row]
//        self.performSegue(withIdentifier: "BranchSegue", sender: BranchSegue)

    }
}
