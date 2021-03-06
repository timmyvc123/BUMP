//
//  Request.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import Foundation

struct Request {
    let builder: RequestBuilder
    let completion: (Result<Data, Error>) -> Void
    
    private static func buildRequest(method: HTTPMethod, header: [String:String], baseURL: String, path: String, params: [String:Any]?=nil, completion: @escaping (Result<Data, Error>) -> Void) -> Request {
        
        let builder = BasicRequestBuilder(method: method, headers: header, baseURL: baseURL, path: path, params: params)
        print("buildRequest's path is...", path)
        
        return Request(builder: builder, completion: completion)
    }
}


extension Request {
    
    static func accessCodeToAccessToken(code: String, completion: @escaping (Result<Tokens, Error>) -> Void) -> Request {
        
        Request.buildRequest(method: .post,
                             header: Header.POSTHeader.buildHeader(),
                             baseURL: SpotifyBaseURL.authBaseURL.rawValue,
                             path: EndingPath.token.buildPath(),
                             params: Parameters.codeForToken(accessCode: code).buildParameters()) { (result) in
            
            result.decoding(Tokens.self, completion: completion)
        }
    }
    
    static func checkExpiredToken(token: String, completion: @escaping (Result<ExpireToken, Error>) -> Void) -> Request {
        
        Request.buildRequest(method: .get,
                             header: Header.GETHeader(accessToken: token).buildHeader(),
                             baseURL: SpotifyBaseURL.APICallBase.rawValue,
                             path: EndingPath.userInfo.buildPath()) { (result) in
            
            result.decoding(ExpireToken.self, completion: completion)
        }
    }
    
    static func refreshTokenToAccessToken(completion: @escaping (Result<Tokens, Error>) -> Void) -> Request? {
        
        guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {return nil}
        
        return Request.buildRequest(method: .post,
                                    header: Header.POSTHeader.buildHeader(),
                                    baseURL: SpotifyBaseURL.authBaseURL.rawValue,
                                    path: EndingPath.token.buildPath(),
                                    params: Parameters.buildParameters(.refreshTokenForAccessCode(refreshToken: refreshToken))()) { result in // the data is passed on to here!
            // makeing decoding call
            result.decoding(Tokens.self, completion: completion)
        }
        
    }
    
    static func createPlaylist(token: String, id: String, name: String, public: Bool, description: String, completions: @escaping (Result<Playlist, Error>) -> Void) -> Request {
        
        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
        
        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
            switch expiredToken {
            case .failure(_):
                print("token still valid")
            case .success(_):
                print("token expired")
                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
                    switch refreshToken {
                    case .failure(_):
                        print("no refresh token returned")
                    case .success(let refresh):
                        print(refresh.accessToken)
                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
                        apiClient.call(request: .createPlaylist(token: token, id: id, name: name, public: true, description: description, completions: completions))
                    }
                })!)
            }
        }))
        
        return Request.buildRequest(method: .get,
                                    header: Header.GETHeader(accessToken: token).buildHeader(),
                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
                                    path: EndingPath.createPlaylist(id: id).buildPath()) { (result) in
            
            result.decoding(Playlist.self, completion: completions)
            
        }
        
    }
    
    static func getUserInfo(token: String, completion: @escaping (Result<UserModel, Error>) -> Void) -> Request {
        
        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
        
        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
            switch expiredToken {
            case .failure(_):
                print("token still valid")
            case .success(_):
                print("token expired")
                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
                    switch refreshToken {
                    case .failure(_):
                        print("no refresh token returned")
                    case .success(let refresh):
                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
                        apiClient.call(request: .getUserInfo(token: refresh.accessToken, completion: completion))
                    }
                })!)
            }
        }))
        
        return Request.buildRequest(method: .get,
                                    header: Header.GETHeader(accessToken: token).buildHeader(),
                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
                                    path: EndingPath.userInfo.buildPath(), params: Parameters.timeRange(range: "long_term").buildParameters()) {
            (result) in
            
            result.decoding(UserModel.self, completion: completion)
        }
    }
    
    static func search(token: String, q: String, type: SpotifyType, market: String, limit: Int, offset: Int, completion: @escaping (Any) -> Void) -> Request {
        
        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
        
        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
            switch expiredToken {
            case .failure(_):
                print("token still valid")
            case .success(_):
                print("token expired")
                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
                    switch refreshToken {
                    case .failure(_):
                        print("no refresh token returned")
                    case .success(let refresh):
                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
                        apiClient.call(request: .search(token: refresh.accessToken, q: q, type: type, market: market, limit: limit, offset: offset, completion: completion))
                    }
                })!)
            }
        }))
        
        return Request.buildRequest(method: .get,
                                    header: Header.GETHeader(accessToken: token).buildHeader(),
                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
                                    path: EndingPath.search(q: q, type: type, market: market, limit: limit, offset: offset).buildPath()) { (result) in
            
            switch type {
            case .track:
                result.decoding(SearchTracks.self, completion: completion)
            default:
                print("this search type not implemented yet!!!")
            }
        }
        
    }
    
//    static func getReccommendations(token: String, limit: Int, market: String?, minAttributes: [(TuneableTrackAttribute, Float)]?, maxAttributes: [(TuneableTrackAttribute, Float)]?, targetAttributes: [(TuneableTrackAttribute, Float)]?, seedArtists: [String]?, seedGenres: [String]?, seedTracks: [String]?, completion: @escaping (Any) -> Void) -> Request {
//        
//        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
//        
//        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
//            switch expiredToken {
//            case .failure(_):
//                print("token still valid")
//            case .success(_):
//                print("token expired")
//                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
//                    switch refreshToken {
//                    case .failure(_):
//                        print("no refresh token returned")
//                    case .success(let refresh):
//                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
//                        apiClient.call(request: .getReccommendations(token: refresh.accessToken, limit: limit, market: market, minAttributes: minAttributes, maxAttributes: maxAttributes, targetAttributes: targetAttributes, seedArtists: seedArtists, seedGenres: seedGenres, seedTracks: seedTracks, completion: completion))
//                    }
//                })!)
//            }
//        }))
//        
//        return Request.buildRequest(method: .get,
//                                    header: Header.GETHeader(accessToken: token).buildHeader(),
//                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
//                                    path: EndingPath.getReccommendations(limit: limit, market: market, minAttributes: minAttributes, maxAttributes: maxAttributes, targetAttributes: targetAttributes, seedArtists: seedArtists, seedGenres: seedGenres, seedTracks: seedTracks).buildPath()) { (result) in
//            
//            result.decoding(Tracks.self, completion: completion) //probably wont work bc of this line
//        }
//        
//    }
    
    static func getUserTopArtists(token: String, completions: @escaping (Result<UserTopArtists, Error>) -> Void) -> Request {
        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
        
        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
            switch expiredToken {
            case .failure(_):
                print("token still valid")
            case .success(_):
                print("token expired")
                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
                    switch refreshToken {
                    case .failure(_):
                        print("no refresh token returned")
                    case .success(let refresh):
                        print(refresh.accessToken)
                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
                        apiClient.call(request: .getUserTopArtists(token: refresh.accessToken, completions: completions))
                    }
                })!)
            }
        }))
        
        return Request.buildRequest(method: .get,
                                    header: Header.GETHeader(accessToken: token).buildHeader(),
                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
                                    path: EndingPath.myTop(type: .artists).buildPath(),
                                    params: Parameters.timeRange(range: "long_term").buildParameters()) { (result) in
            
            result.decoding(UserTopArtists.self, completion: completions)
            
        }
        
    }
    
    static func getUserTopTracks(token: String, completions: @escaping (Result<UserTopTracks, Error>) -> Void) -> Request {
        
        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
        
        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
            switch expiredToken {
            case .failure(_):
                print("token still valid")
            case .success(_):
                print("token expired")
                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
                    switch refreshToken {
                    case .failure(_):
                        print("no refresh token returned")
                    case .success(let refresh):
                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
                        apiClient.call(request: .getUserTopTracks(token: refresh.accessToken, completions: completions))
                    }
                })!)
            }
        }))
        
        return Request.buildRequest(method: .get,
                                    header: Header.GETHeader(accessToken: token).buildHeader(),
                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
                                    path: EndingPath.myTop(type: .tracks).buildPath(), params: Parameters.timeRange(range: "long_term").buildParameters()) {
            (result) in
            
            result.decoding(UserTopTracks.self, completion: completions)
            
        }
        
    }
    
    static func getPlaylist(token: String, playlistId: String, completions: @escaping (Result<Playlist, Error>) -> Void) -> Request {
        
        let apiClient = APIClient(configuration: URLSessionConfiguration.default)
        
        apiClient.call(request: .checkExpiredToken(token: token, completion: { (expiredToken) in
            switch expiredToken {
            case .failure(_):
                print("token still valid")
            case .success(_):
                print("token expired")
                apiClient.call(request: refreshTokenToAccessToken(completion: { (refreshToken) in
                    switch refreshToken {
                    case .failure(_):
                        print("no refresh token returned")
                    case .success(let refresh):
                        print(refresh.accessToken)
                        UserDefaults.standard.set(refresh.accessToken, forKey: "token")
                        apiClient.call(request: .getPlaylist(token: refresh.accessToken, playlistId: playlistId, completions: completions))
                    }
                })!)
            }
        }))
        
        return Request.buildRequest(method: .get,
                                    header: Header.GETHeader(accessToken: token).buildHeader(),
                                    baseURL: SpotifyBaseURL.APICallBase.rawValue,
                                    path: EndingPath.playlist(id: playlistId).buildPath()) { (result) in
            
            result.decoding(Playlist.self, completion: completions)
            
        }
        
    }
    
}



public extension Result where Success == Data, Failure == Error {
    
    // make a decoding function with generic input
    func decoding<M: Model>(_ model: M.Type, completion: @escaping (Result<M, Error>) -> Void) {
        
        DispatchQueue.global().async {
            // decodes the data using flatMap
            let result = self.flatMap { data -> Result<M, Error> in
                do {
                    let decoder = M.decoder
                    let model = try decoder.decode(M.self, from: data)
                    return .success(model)
                } catch {
                    return .failure(error)
                }
            }
            DispatchQueue.main.async {
                // pass parsed data to completion
                completion(result)
            }
        }
    }
}
