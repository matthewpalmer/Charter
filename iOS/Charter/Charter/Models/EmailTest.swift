//
//  EmailTest.swift
//  Charter
//
//  Created by Matthew Palmer on 20/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Charter

class EmailTest: XCTestCase {
    var realm: Realm!
    
    override func setUp() {
        super.setUp()
        realm = setUpTestRealm()
    }
    
    func testInitFromJSONWhenMessageIsMemberOfAThreadAndRealmIsEmpty() {
        let email = try! Email.createFromData(dataForJSONFile("MemberEmail"), inRealm: realm)
        
        // Other properties are asserted in `testInitFromJSONWhenMessageIsTheRootOfAThreadAndRealmIsEmpty`.
        // This test focuses on the relationship-building JSON entries.
        XCTAssertEqual(email.id, "etPan.5694130e.68c32b25.9260@Jareds-MacBook-Pro-13-Inch.local")
        
        let references = ["CANFz0qvo4omuHqhrCgKrcNFLwJZSr15HzriwtkHSQSPukBHCzQ@mail.gmail.com"]
        XCTAssertEqual(email.references.map { $0.id }, references)
        
        let descendants = [
            "FF8008ED-6555-4B04-9EDE-6B6EE0E70D58@apple.com",
            "CAG-XJx=bWrczPRZbmvDkXHtcgU4F7BR5-Sjp4VAqD7JwhDSp3Q@mail.gmail.com"
        ]
        XCTAssertEqual(email.descendants.map { $0.id }.sort(), descendants.sort())
        
        XCTAssertEqual(email.inReplyTo?.id, "CA+Y5xYevdEEvKxtk9ys3GzZ2O+Ajj3k7u5ZedSOVM4P1NQcObQ@mail.gmail.com")
        
        // Assert that these things were added to the realm
        XCTAssertEqual(realm.objects(Email).count, references.count + descendants.count + 2) // + 2 for inReplyTo and original email
    }
    
    func testInitFromJSONWhenMessageIsTheRootOfAThreadAndRealmIsEmpty() {
        let data = dataForJSONFile("RootEmail")
        let email = try! Email.createFromData(data, inRealm: realm)
        
        // Assert the `email` instance is correct.
        XCTAssertEqual(email.id, "m2ziv7yyt9.fsf@eno.apple.com")
        XCTAssertEqual(email.from, "dabrahams at apple.com (Dave Abrahams)")
        XCTAssertEqual(email.mailingList, "swift-evolution")
        XCTAssertEqual(email.content, "Hi All,\n\nThe API guidelines working group took up the issue of the InPlace suffix\nyesterday, and decided that it was not to be used anywhere in the\nstandard library.  We are planning to apply the changes shown here\n<https://gist.github.com/dabrahams/d872556291a3cb797bd5> to the API of\nSetAlgebra (and consequently Set) to make it conform to the guidelines\nunder development.\n\nComments welcome as usual,\n\n-- \n-Dave")
        XCTAssertEqual(email.archiveURL, "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009684.html")
        XCTAssertEqual(email.subject, "[swift-evolution] ed/ing, InPlace, Set/SetAlgebra naming resolution")
        XCTAssertEqual(email.inReplyTo, nil)
        
        let dateString = "2016-02-11 16:52:18 +0000"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let date = dateFormatter.dateFromString(dateString)
        XCTAssertEqual(email.date, date)
        
        XCTAssertEqual(Array(email.references), [])
        
        let descendants = [
            "A8FC326B-7A87-447F-944F-10EBCC1AA9B3@mac.com",
            "B62D971D-218B-423B-81F1-86DB94487A22@me.com",
            "7F4D5AE3-930B-44A9-A16B-6F3F10B43A0D@mac.com",
            "4E0D96AB-9B82-470D-A655-A06AF69CB927@architechies.com",
            "960645F0-384C-4D45-9475-1295D001C9FD@architechies.com",
            "m237ss5uuv.fsf@eno.apple.com",
            "7EA11508-D8E0-4E99-99AD-D6B9A375A58E@novafore.com",
            "m2r3gia1gj.fsf@eno.apple.com",
            "E4BEA678-3F7A-4A9F-BC17-F10E1B9F5659@owensd.io",
            "B262CDAE-3C44-40FB-93B1-C273871B381F@apple.com",
            "1B77C118-25E0-43EE-BB72-D3B808509FB0@owensd.io",
            "F37EAA18-FC7C-41E0-B275-F59C024FFE71@apple.com",
            "F35DF9C5-0837-427B-A266-A6812A27B3BB@owensd.io",
            "3667619A-5295-44F4-B259-195D791348F0@me.com",
            "m2r3gh60bz.fsf@eno.apple.com",
            "m2d1s14gdq.fsf@eno.apple.com",
            "EC6F7264-1DD6-4371-80B7-0B2FE5A5C8C5@mac.com",
            "660DC148-7CA7-4301-9E82-9FEB82AA9A89@mac.com",
            "CCBBE04D-991B-4655-AE88-EEA8D11843E7@gmail.com",
            "50436AA8-1BFD-4FF9-8CC2-A19E02490CFE@uzh.ch",
            "m2y4ao354l.fsf@eno.apple.com",
            "299ADA6E-54A2-4BD8-B773-94D23BEE98CF@icloud.com",
            "m2pow0z9s3.fsf@eno.apple.com",
            "F4861D75-6150-480D-BCC5-A238F40CF7BF@novafore.com",
            "C9ACE38E-10E0-4B38-8444-0443CA87BD88@gmail.com",
            "2753A39C-BEC6-47B2-AA9C-EB4A652B148A@architechies.com",
            "m2a8n4z4sm.fsf@eno.apple.com",
            "m2h9hbxnoi.fsf@eno.apple.com",
            "m237svxn3w.fsf@eno.apple.com",
            "96B1E92E-5587-4B90-94C3-4ECF678AB3D6@novafore.com",
            "AE630228-0A45-4B83-8D7E-14A9E9147F64@hartbit.com",
            "m2wpq7vx09.fsf@eno.apple.com",
            "7876666B-9AD2-4182-992E-B5525B3DC98A@aol.com",
            "CAGY80un4tr=Gjc+iFEK5cj1y9HD21yR9x3U500z5A0KOR+BGSQ@mail.gmail.com",
            "4CE7B43A-03FA-4DC4-8E75-C826045C4B4A@aol.com",
            "49CE0188-3042-434F-9BDC-3984480B6817@mac.com",
            "648999C7-881B-443F-826B-4058E0575A50@apple.com",
            "CACR_FB5GAdzdMS+q6MHm8ymXQPMSyxNvS5PLjWJtFT96uK3DTw@mail.gmail.com",
            "CAGY80uk7AQR5Xz_SFffr5j07Y+pjRFzuHN52wMqMMP1FcTYwTQ@mail.gmail.com",
            "144F4695-6BA1-4C55-8A69-65F7835FED1C@mac.com",
            "CANGnqV3H+Zcaz0jbYG+pLyYpjTVw4zmnCO+UbNwZE2tt2mcAtQ@mail.gmail.com",
            "9C736880-B61A-493E-A9B6-7957CAF3B6B8@me.com",
            "3A28E134-D038-4FC6-AAA1-E20FB54AE29C@novafore.com",
            "CAGY80un5AR7O6ctBGXemPGZU9Xgbpc8jpx-heZVnN0FR68A0CA@mail.gmail.com",
            "3860288B-D504-485D-861D-5FFC2A16ED2C@apple.com",
            "m2bn7hu6lw.fsf@eno.apple.com",
            "7D9A827C-357F-4493-9BA6-61FCA91DD5CD@apple.com",
            "CAGY80u=+0K0i=4c8nMX0nsowG2jtDdhbuANZhdKOBo89_jgxPw@mail.gmail.com",
            "227F5F93-BAD7-42EE-B7B0-5937431EB4EC@icloud.com",
            "9896E9CD-8DC6-42EA-A0BB-584C79501F8F@novafore.com",
            "53C6E239-6F63-4790-85C9-F50C213103A6@me.com",
            "4BDB1AC4-3918-46A2-8167-E06D909D0560@novafore.com",
            "D16D314D-C05A-4784-8D70-BFFE8AEE5682@icloud.com",
            "2365FF46-BDCF-4BC0-9050-C8E9DB8A4CF7@novafore.com",
            "76E902E8-4C70-4C3F-96CD-2942F8DD3384@ericasadun.com",
            "8B1B13A5-442A-4DCE-B9D8-410552C1CE21@novafore.com",
            "CADcs6kPScP9s3m2YVUENy+KHmeO4VbJhUJE6TQwj6B621Z6wwQ@mail.gmail.com",
            "CAGY80ukwYNLGCkhUsc7zTbTt4xZEeCud71-wCx5LC=NTojhqhw@mail.gmail.com",
            "A3854C05-14D7-4686-8FFB-6C37729BED77@apple.com",
            "9953B953-CED8-42E5-B665-67EF52FCE82A@ericasadun.com",
            "3EA8C7F5-E3D6-4FB2-95DE-739D9B5F2259@ericasadun.com",
            "CADcs6kOXB6Ak_gJVcJcjNy0ySPbOPfmo0f5t9farRn-Yx-fCnw@mail.gmail.com",
            "09DB5774-C20F-4B00-AC39-3B9ECAF309A5@akkyra.com",
            "6378ED7E-F0A0-4C60-884E-9B61433F66CA@ericasadun.com",
            "CAGY80ungx6M3srmcjED1TnS3dhAvFC1SZjT4uGgU9Jx=cuvzMg@mail.gmail.com",
            "24CB3821-B699-4F9D-B084-BC02CB456387@apple.com",
            "CADcs6kNATModezcKKqciVhKdAhP7aqapWMS_yJn-HK8nphZ+VQ@mail.gmail.com",
            "E5D2D8D8-E733-434B-8044-98DE0860812A@ericasadun.com",
            "CAGY80umV=X_RhGvuVJZGKtJCoO-6xXBUujSmhxi3jnUAK-_ahg@mail.gmail.com",
            "6136A42A-433F-4675-B115-871FF3248971@me.com",
            "CAGefD4MoAgczY7T1nJyi57b-VpW+sBWmapsErUZmfvztYKJZgg@mail.gmail.com",
            "A20884F4-1165-4188-9D95-EFAE7821D032@gmail.com",
            "D1CD66EF-C8F4-47EF-BBEB-FD3E31C33588@lng.la",
            "m28u2qx43z.fsf@eno.apple.com",
            "5380D783-1ED6-4D2A-9C09-1DB321AF6C1D@gmail.com",
            "BCDF997B-6F18-4DB3-91BB-C75ACB288788@lng.la",
            "5B0A1922-41B7-4851-9211-AF3FB132D595@pobox.com",
            "m2lh6qvnux.fsf@eno.apple.com",
            "CAGY80ukwZQ6j89O7GZQwrfvUxjjqqrJgHUS3wB=VuHE3nsJnhA@mail.gmail.com",
            "m2twlevods.fsf@eno.apple.com",
            "666286C9-A32C-4862-919F-46403FA74C22@ericasadun.com",
            "1C96914E-15C7-461E-A953-DFCB8F7CBABE@apple.com",
            "CAGY80ukOgEaTnG92PWJuGrBkpxZHoOYVOtsZ8Yvyiq9dzoFESA@mail.gmail.com",
            "C194A9C5-2EA4-4D73-A686-D841724F541C@architechies.com",
            "3AD3381B-A7E0-4528-9DC3-06250D0429C4@apple.com",
            "D9F0708F-F9F2-40FF-AA05-61D3C07EC3C0@lng.la",
            "A2578CEB-50CB-4F0C-BD49-17585E164DC8@apple.com",
            "CAGY80u=rwWF16b_5vc9DMQ0STH1jp32VVEvPfzndKTseGxYR=A@mail.gmail.com",
            "m2d1s2vlps.fsf@eno.apple.com",
            "F836F2DC-47C3-474A-9767-B574643541B3@apple.com",
            "DE3AF87C-BAC4-4651-BD2A-27B5EDFC828F@me.com",
            "CAGY80unFC41Lnf+Sajx6Jd0nc6dHE40hG7DHPZN815A207fqUw@mail.gmail.com",
            "C595731D-D350-40C4-846D-06AF801B9E6F@mac.com",
            "m24mdevhu3.fsf@eno.apple.com",
            "E4D05236-3C18-4A11-9258-FCDE0AA80198@architechies.com",
            "m2y4aqu35r.fsf@eno.apple.com",
            "m2mvr6u2z7.fsf@eno.apple.com",
            "m2h9heu2xd.fsf@eno.apple.com",
            "m2si0yu32u.fsf@eno.apple.com",
            "CAGY80ukfTtHJUOjLgBTowt8eLz=v8X9k8QKVVzi-JCLkUucTYg@mail.gmail.com",
            "B7AEEAD8-43D9-44CC-BCAF-77CDC1CC9719@me.com",
            "E1D07E90-531F-4BCF-87E7-3C221E262FA1@me.com",
            "m27fiabhhx.fsf@eno.apple.com",
            "m21t8ibgzi.fsf@eno.apple.com",
            "m260xua0bj.fsf@eno.apple.com",
            "CAGY80u=qd_WCLKCJRNg49QbBo9=DmfTci0x+iowZzcpa+ExA_g@mail.gmail.com",
            "CAGY80u=6wNA+JEH58EVPAjMrJ6zRFGe8VKU9QZ5DeHBKGjcbow@mail.gmail.com",
            "C4C6257A-A186-4831-BB21-0303E32D2A0B@apple.com",
            "77CA3E70-A7B7-4FFF-B817-F85AB79D04FC@gmail.com",
            "CBBE8D69-5D3A-4E7A-AC74-445347179CA8@uzh.ch",
            "CANq73XOvwfuC=gQY8qN7G6JdJ-EKHYB96F1DpfoDDpkJKwZ5LQ@mail.gmail.com",
            "A6CEE025-BCB5-4729-8BA1-BB8A5C8CB03F@icloud.com",
            "E5C8E08F-4D35-42A3-9B58-E2E393AD5D74@icloud.com",
            "FD766F1E-F333-441B-8DA0-4E8205A1A1C5@novafore.com",
            "4D456C5F-72B5-4CA0-AA2A-DDA300E6113B@owensd.io",
            "56BDDDC5.8010008@brockerhoff.net",
            "4C153A86-C3C7-464B-BD79-A80EC276805F@apple.com",
            "m2vb5t7uz8.fsf@eno.apple.com",
            "0C507CF8-4D22-4009-8EB8-978EE33B2956@gmail.com",
            "8E7A694C-E47E-4BF5-90FF-F1E3FA9B3E61@gilt.com",
            "BF16570F-261E-45F5-B319-448B8E6C4815@novafore.com",
            "9004F40B-EB9D-440B-A63B-3EE836876636@novafore.com",
            "613F72D3-51BA-4554-9393-E6793AB6B876@owensd.io",
            "CANFz0qvfcPDa0cDLrJOA=s9dOxoo6UhYXZwgqXAx4jWGF5wBQg@mail.gmail.com",
            "m2lh6p603p.fsf@eno.apple.com",
            "DC5437D3-F942-4EC7-84A4-F2F012501E39@ucdavis.edu",
            "m2pow033r1.fsf@eno.apple.com",
            "919DA31D-F366-4A4F-9F9D-44D289BA41CE@novafore.com",
            "m2egcg1lun.fsf@eno.apple.com",
            "m2io1s3285.fsf@eno.apple.com",
            "7A3A651D-8AD3-4012-AC7C-23E13D535D9D@gmail.com",
            "m2ziv4za9r.fsf@eno.apple.com",
            "0E14ABA8-3818-4497-80CC-030A8FA5F139@mac.com",
            "E6D98C0B-096E-4F8E-9E44-197D5B938972@aol.com",
            "5389D1B5-0C8A-4474-9C56-1210CC50BFBB@uzh.ch",
            "8F3A7B56-EE19-4E67-A190-086F22481F24@dimsumthinking.com",
            "F13D9E94-9557-4B23-82F3-4B72B639DAFB@dimsumthinking.com",
            "m2povzxogh.fsf@eno.apple.com",
            "EA1B1AA9-41F7-4602-806A-6949852BF803@hartbit.com",
            "m2d1rzxnjz.fsf@eno.apple.com",
            "BC7A6FB6-4AFC-4705-9560-B78D1C2432F5@icloud.com",
            "71EEA366-9429-43C0-8236-33E922BA8975@mac.com",
            "m260xqwyxm.fsf@eno.apple.com",
            "m2egcfvwmm.fsf@eno.apple.com",
            "CAGkFtXx=36Px6VPa4HCNOU+NDufJBu=Dh6ZTOKwniVwm7osMbw@mail.gmail.com",
            "968F0F8D-FC55-4913-A460-69F15A53E7E6@me.com"
        ]
        
        zip(email.descendants.map { $0.id }.sort(), descendants.sort()).forEach {
            XCTAssertEqual($0.0, $0.1)
        }
        
        email.descendants.forEach { XCTAssertFalse($0.isComplete) }

        // Assert that Realm had the right stuff added
        let emailFromRealm = realm.objects(Email).filter("id == 'm2ziv7yyt9.fsf@eno.apple.com'").first
        XCTAssertEqual(emailFromRealm, email)
        XCTAssertEqual(realm.objects(Email).count, descendants.count + 1) // All descendants plus the original email should be added
    }
    
    func testInitFromJSONForThreadWhereRealmIsNotEmpty() {
        // Example scenario: loading from the main feed.
        // This test asserts that the right relationships are formed when the realm already contains data; other tests assert that the right fields get set with values.
        
        // 1. User requests the "threads" endpoint, which gives us a root email for the thread and references for the other emails in the thread (but these are incomplete)
        let email1 = try! Email.createFromData(dataForJSONFile("PreexistingEmail1"), inRealm: realm)
        
        XCTAssertEqual(email1.id, "1")
        XCTAssertEqual(email1.descendants.map { $0.id }.sort(), ["2", "3", "4"].sort())
        XCTAssertEqual(email1.descendants.map { $0.isComplete }, [false, false, false])
        XCTAssertNil(email1.inReplyTo)
        XCTAssertEqual(email1.references.count, 0)
        
        // 2. User goes into the "thread" and the sub-emails are retrieved.
        let email2 = try! Email.createFromData(dataForJSONFile("PreexistingEmail2"), inRealm: realm)
        XCTAssertEqual(email2.id, "2")
        XCTAssertEqual(email2.descendants.map { $0.id }.sort(), ["3", "4"].sort())
        XCTAssertEqual(email2.inReplyTo, email1)
        XCTAssertEqual(email1.descendants.filter { $0.id == "2" }.first!.subject, email2.subject)
        
        let email3 = try! Email.createFromData(dataForJSONFile("PreexistingEmail3"), inRealm: realm)
        XCTAssertEqual(email3.content, "Pre existing three")
        XCTAssertEqual(email3.inReplyTo, email2)
        
        let email4 = try! Email.createFromData(dataForJSONFile("PreexistingEmail4"), inRealm: realm)
        XCTAssertEqual(email4.inReplyTo, email3)
        XCTAssertEqual(email4.references.sort({ $0.id > $1.id }), [email3, email2, email1].sort({ $0.id > $1.id }))
        XCTAssertEqual(email1.descendants.sort({$0.id > $1.id}), [email4, email3, email2].sort({$0.id > $1.id}))
    }
    
    func testInitFromJSONWhereRequiredFieldsAreNotPresent() {
        let expectation = expectationWithDescription("Should throw if not present")
        
        do {
            let _ = try Email.createFromData(dataForJSONFile("EmailInvalid"), inRealm: realm)
        } catch {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testInitFromJSONWhereOptionalFieldsAreNotPresent() {
        let email = try! Email.createFromData(dataForJSONFile("EmailValidButPartial"), inRealm: realm)
        XCTAssertEqual(email.id, "b32b4d86-d703-4075-9c5d-da46bbac808b@me.com")
        XCTAssertEqual(Array(email.references), [])
        XCTAssertEqual(email.inReplyTo, nil)
        XCTAssertEqual(Array(email.descendants), [])
    }
    
    func testInitFromNetworkEmailWhereEmailReferencesItself() {
        let networkEmail = NetworkEmail(id: "one@example.com", from: "f", mailingList: "list", content: "content", archiveURL: "archiv", date: NSDate(), subject: "subjecg", inReplyTo: "one@example.com", references: ["one@example.com"], descendants: ["one@example.com"])
        let email = try! Email.createFromNetworkEmail(networkEmail, inRealm: realm)
        XCTAssertEqual(email.id, "one@example.com")
        XCTAssertEqual(email.references.first!.id, email.id)
        XCTAssertEqual(email.references.first!.content, email.content)
        XCTAssertEqual(email.descendants.first!.id, email.id)
        XCTAssertEqual(email.descendants.first!.content, email.content)
        XCTAssertEqual(email.inReplyTo!.id, email.id)
    }
    
    func testInReplyTo() {
        let originalId = "D8CF8D02-509C-40A8-8589-2C59C0201F39@apple.com"
        let inReplyTo: String = "880C49F5-11DF-4368-B3DF-A5ECB0CAC515@gmail.com"
        let references: [String] = [
            "CADcs6kMMqbtWS1_gByxYUO=+ET8V+iJYXaaGrqVx5Sq-=M37_A@mail.gmail.com",
            "986FDA06-FE79-4310-9FB7-21E9AEF25B51@apple.com",
            "880C49F5-11DF-4368-B3DF-A5ECB0CAC515@gmail.com"]
        let descendants: [String] = [
            "D8CF8D02-509C-40A8-8589-2C59C0201F39@apple.com",
            "CADcs6kOm7nBk78fZkOBYWa85dX=j4hrWUQk4AaYyJ6Yb5T2Vqg@mail.gmail.com",
            "7C0783FC-B039-4F0E-BF68-D992380B37CF@gmail.com",
            "BE52EDE6-A109-49F7-BE7B-876BF2950578@apple.com",
            "9643FE18-C60C-4B0C-A23D-0B9B2CA06908@gmail.com"
        ]
        
        let networkEmail = NetworkEmail(id: originalId, from: "Joe", mailingList: "s", content: "c", archiveURL: "a", date: NSDate(), subject: "s", inReplyTo: inReplyTo, references: references, descendants: descendants)
        let email = try! Email.createFromNetworkEmail(networkEmail, inRealm: realm)
        
        XCTAssertEqual(email.id, originalId)
        XCTAssertEqual(email.references.map { $0.id }.sort(), references.sort())
    }
}
