//
//  gitTestTests.swift
//  gitTestTests
//
//  Created by Ankur Sehdev on 04/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import XCTest
@testable import gitTest

class gitTestTests: XCTestCase {
    var sut: RepositoryVC!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = RepositoryVC()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func testReposAfterLogout(){
        sut.clearData()
        XCTAssertEqual(sut!.repos.count, 0,"repos deleted")
    }
    
    func testGitTokenAfterLogout()  {
        sut.clearData()
        let token = UserDefaults.standard.value(forKey: "gitToken")
        XCTAssertNil(token)
    }
    func testGitTokenAfterLogoutLocal()  {
        sut.clearData()
        XCTAssertEqual(sut.token, "")
    }
    func testGitToken()  {
        // If logged in
        let token = UserDefaults.standard.value(forKey: "gitToken")
        XCTAssertNil(token)
    }
    
}
