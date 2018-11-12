//
//  API.swift
//  Dev
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation
import concorde
import Crypto
import PostgreSQL

struct User: Codable {
    let id: Int?
    let username: String
    let password: String
}

struct SignedInUser {
    let id: Int?
    let token: String
}

struct Item: Codable {
    let id: Int?
    let userid: Int
    let title: String
    let date: Int
    let content: String
}

func psql(with req: Request) -> Future<PostgreSQLConnection> {
    return req.cached(PostgreSQLConnection.self)
}

func add(with conn: PostgreSQLConnection, user: User) -> Future<[User]> {
    return conn
        .raw(insertUser())
        .bind(user.username)
        .bind(user.password)
        .all(decoding: User.self)
}

func insertUser() -> String {
    return """
        INSERT INTO "public"."users"("id", "username", "password")
        VALUES(DEFAULT, $1, $2)
        RETURNING "id", "username", "password";
    """
}

func converting<T: Codable>(_ item: T) -> Response {
    return Response(item)
}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

func signUp(req: Request) -> Future<Response> {
    let user = req.body <^> decode(User.self)
    let t = psql(with: req).flatMap { conn in
        user.flatMap { user -> Future<[User]>  in
            if let user = user {
                return add(with: conn, user: user)
            } else {
                 throw "error"
            }
        }
    }
    return t <^> converting
}

func selectItems() -> String {
    return """
        SELECT * FROM items WHERE userid = $1
    """
}

func getItems(userId: Int) -> (PostgreSQLConnection) -> Future<[Item]> {
    return { conn in
        conn.raw(selectItems()).bind(userId).all(decoding: Item.self)
    }
}

func items(userId: Int, req: Request) -> Future<Response> {
    return (psql(with: req) >>- getItems(userId: userId)) <^> converting
}
