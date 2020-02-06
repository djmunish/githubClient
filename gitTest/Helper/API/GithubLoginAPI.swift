//
//  GithubLoginAPI.swift
//  BaseAPI
//
//  Created by Serhii Londar on 6/7/19.
//

import Foundation

class GithubLoginAPI {
    enum Parameters: String {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case code
        case redirectURL = "redirect_uri"
    }
    public typealias BaseAPICompletion = (Data?, URLResponse?, Error?) -> Swift.Void
    var session: URLSession
    public init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
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
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
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

}
