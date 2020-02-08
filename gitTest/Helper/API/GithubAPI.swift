//
//  GithubLoginAPI.swift
//  BaseAPI
//
//  Created by Serhii Londar on 6/7/19.
//

import Foundation

class GithubAPI {
    static let gitClient = GithubAPI()
    enum Parameters: String {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case code
        case redirectURL = "redirect_uri"
    }
    public typealias BaseAPICompletion = (Data?, URLResponse?, Error?) -> Swift.Void
    var session: URLSession
    public init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }
    
    public init(session: URLSession) {
        self.session = session
    }
    public func getAccessToken(clientID: String, clientSecret: String, code: String, redirectURL: String, completion: @escaping(AccessTokenResponse?, Error?) -> Void) {
        let url = "https://github.com/login/oauth/access_token"
        
        var parameters = [String : String]()
        parameters[Parameters.clientID.rawValue] = clientID
        parameters[Parameters.clientSecret.rawValue] = clientSecret
        parameters[Parameters.code.rawValue] = code
        parameters[Parameters.redirectURL.rawValue] = redirectURL

        var headers = [String : String]()
        headers["Accept"] = "application/json"
        
        self.get(url: url, parameters: parameters, headers: headers) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func get(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .GET, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    func getRepos(accesstoken:String, completion: @escaping([RepositoryResponse]?, Error?) -> Void){
        let url = "https://api.github.com/user/repos?access_token=\(accesstoken)"
        self.get(url: url, parameters: nil, headers: nil) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode([RepositoryResponse].self, from: data)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getBranches(accesstoken:String, ownerName : String, repoName : String, completion: @escaping([BranchResponse]?, Error?) -> Void){
        let url = "https://api.github.com/repos/\(ownerName)/\(repoName)/branches?access_token=\(accesstoken)"
        
        self.get(url: url, parameters: nil, headers: nil) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode([BranchResponse].self, from: data)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getLastCommit(accesstoken:String, url:String, completion: @escaping(CommitResponse?, Error?) -> Void){
        let url = "\(url)?access_token=\(accesstoken)"
        
        self.get(url: url, parameters: nil, headers: nil) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(CommitResponse.self, from: data)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getPullRequests(accesstoken:String, ownerName : String, repoName : String, branch: String, completion: @escaping([PullRequestResponse]?, Error?) -> Void){
        let url = "https://api.github.com/repos/\(ownerName)/\(repoName)/pulls?access_token=\(accesstoken)&state=all&base=\(branch)"
        self.get(url: url, parameters: nil, headers: nil) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode([PullRequestResponse].self, from: data)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func updatePRStatus(accesstoken:String, ownerName : String, repoName : String, prNumber: Int, completion: @escaping(PullRequestUpdateResponse?, Error?) -> Void){
        let url = "https://api.github.com/repos/\(ownerName)/\(repoName)/pulls/\(String(describing: prNumber))/merge"
        
        self.put(url: url, headers: ["Authorization" : "Bearer \(accesstoken)"]) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(PullRequestUpdateResponse.self, from: data)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func rejectPRStatus(accesstoken:String, ownerName : String, repoName : String, prNumber: Int, completion: @escaping(RejectPullRequestResponse?, Error?) -> Void){
        let url = "https://api.github.com/repos/\(ownerName)/\(repoName)/pulls/\(String(describing: prNumber))?state=closed"
        
        self.patch(url: url, headers: ["Authorization" : "Bearer \(accesstoken)"]) { (data, _, error) in
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(RejectPullRequestResponse.self, from: data)
//                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
                    completion(model, error)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func put(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .PUT, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    public func patch(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .PATCH, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }

}
