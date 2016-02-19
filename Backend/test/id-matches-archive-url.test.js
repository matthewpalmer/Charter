const idMatchesArchiveURL = require('../id-matches-archive-url');

const nock = require('nock');
const expect = require('expect.js');
const sinon = require('sinon');
const validateArchiveURL = require('../validate-archive-url');

nock.disableNetConnect();

var match = {
  "_id" : "1A5116CD-1758-40FC-81F1-6CFD4C38158E@apple.com",
  "archiveURL" : "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009858.html"
};

const matchSource = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><HTML> <HEAD>   <TITLE> [swift-evolution] [Review] SE-0027 Expose code unit initializers on String   </TITLE>   <LINK REL="Index" HREF="index.html" >   <LINK REL="made" HREF="mailto:swift-evolution%40swift.org?Subject=Re:%20Re%3A%20%5Bswift-evolution%5D%20%5BReview%5D%20SE-0027%20Expose%20code%20unit%0A%20initializers%20on%20String&In-Reply-To=%3C1A5116CD-1758-40FC-81F1-6CFD4C38158E%40apple.com%3E">   <META NAME="robots" CONTENT="index,nofollow">   <style type="text/css">       pre {           white-space: pre-wrap;       /* css-2.1, curent FF, Opera, Safari */           }   </style>   <META http-equiv="Content-Type" content="text/html; charset=utf-8">   <LINK REL="Previous"  HREF="009836.html">   <LINK REL="Next"  HREF="009865.html"> </HEAD> <BODY BGCOLOR="#ffffff">   <H1>[swift-evolution] [Review] SE-0027 Expose code unit initializers on String</H1>    <B>Tony Parker</B>     <A HREF="mailto:swift-evolution%40swift.org?Subject=Re:%20Re%3A%20%5Bswift-evolution%5D%20%5BReview%5D%20SE-0027%20Expose%20code%20unit%0A%20initializers%20on%20String&In-Reply-To=%3C1A5116CD-1758-40FC-81F1-6CFD4C38158E%40apple.com%3E"       TITLE="[swift-evolution] [Review] SE-0027 Expose code unit initializers on String">anthony.parker at apple.com       </A><BR>    <I>Thu Feb 11 20:15:18 CST 2016</I>    <P><UL>        <LI>Previous message: <A HREF="009836.html">[swift-evolution] [Review] SE-0027 Expose code unit initializers on  String</A></li>        <LI>Next message: <A HREF="009865.html">[swift-evolution] [Review] SE-0027 Expose code unit initializers on String</A></li>         <LI> <B>Messages sorted by:</B>               <a href="date.html#9858">[ date ]</a>              <a href="thread.html#9858">[ thread ]</a>              <a href="subject.html#9858">[ subject ]</a>              <a href="author.html#9858">[ author ]</a>         </LI>       </UL>    <HR>  <!--beginarticle--><PRE>Hi Doug, Zachary,Can you provide more clarification on why the static func is needed? It seems like the functionality is all about initialization and therefore belongs in an initializer (as is also proposed).- Tony&gt;<i> On Feb 11, 2016, at 4:41 PM, Douglas Gregor via swift-evolution &lt;<A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">swift-evolution at swift.org</A>&gt; wrote:</I>&gt;<i> </I>&gt;<i> Hello Swift community,</I>&gt;<i> </I>&gt;<i> The review of SE-0027 &quot;Expose code unit initializers on String&quot; begins now and runs through February 16, 2016. The proposal is available here:</I>&gt;<i> </I>&gt;<i> <A HREF="https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md">https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md</A> &lt;<A HREF="https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md">https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md</A>&gt;</I>&gt;<i> Reviews are an important part of the Swift evolution process. All reviews should be sent to the swift-evolution mailing list at</I>&gt;<i> </I>&gt;<i> <A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">https://lists.swift.org/mailman/listinfo/swift-evolution</A> &lt;<A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">https://lists.swift.org/mailman/listinfo/swift-evolution</A>&gt;</I>&gt;<i> or, if you would like to keep your feedback private, directly to the review manager. When replying, please try to keep the proposal link at the top of the message:</I>&gt;<i> </I>&gt;<i> Proposal link:</I>&gt;<i> </I>&gt;<i> <A HREF="https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md">https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md</A> &lt;<A HREF="https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md">https://github.com/apple/swift-evolution/blob/master/proposals/0027-string-from-code-units.md</A>&gt;</I>&gt;<i> Reply text</I>&gt;<i> </I>&gt;<i> Other replies</I>&gt;<i>  &lt;<A HREF="https://github.com/apple/swift-evolution#what-goes-into-a-review-1">https://github.com/apple/swift-evolution#what-goes-into-a-review-1</A>&gt;What goes into a review?</I>&gt;<i> </I>&gt;<i> The goal of the review process is to improve the proposal under review through constructive criticism and, eventually, determine the direction of Swift. When writing your review, here are some questions you might want to answer in your review:</I>&gt;<i> </I>&gt;<i> What is your evaluation of the proposal?</I>&gt;<i> Is the problem being addressed significant enough to warrant a change to Swift?</I>&gt;<i> Does this proposal fit well with the feel and direction of Swift?</I>&gt;<i> If you have used other languages or libraries with a similar feature, how do you feel that this proposal compares to those?</I>&gt;<i> How much effort did you put into your review? A glance, a quick reading, or an in-depth study?</I>&gt;<i> More information about the Swift evolution process is available at</I>&gt;<i> </I>&gt;<i> <A HREF="https://github.com/apple/swift-evolution/blob/master/process.md">https://github.com/apple/swift-evolution/blob/master/process.md</A> &lt;<A HREF="https://github.com/apple/swift-evolution/blob/master/process.md">https://github.com/apple/swift-evolution/blob/master/process.md</A>&gt;</I>&gt;<i> Thank you,</I>&gt;<i> </I>&gt;<i> Doug Gregor</I>&gt;<i> </I>&gt;<i> Review Manager</I>&gt;<i> </I>&gt;<i> _______________________________________________</I>&gt;<i> swift-evolution mailing list</I>&gt;<i> <A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">swift-evolution at swift.org</A></I>&gt;<i> <A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">https://lists.swift.org/mailman/listinfo/swift-evolution</A></I>-------------- next part --------------An HTML attachment was scrubbed...URL: &lt;<A HREF="https://lists.swift.org/pipermail/swift-evolution/attachments/20160211/ac87ee84/attachment.html">https://lists.swift.org/pipermail/swift-evolution/attachments/20160211/ac87ee84/attachment.html</A>&gt;</PRE><!--endarticle-->    <HR>    <P><UL>        <!--threads--> <LI>Previous message: <A HREF="009836.html">[swift-evolution] [Review] SE-0027 Expose code unit initializers on String</A></li> <LI>Next message: <A HREF="009865.html">[swift-evolution] [Review] SE-0027 Expose code unit initializers on String</A></li>         <LI> <B>Messages sorted by:</B>               <a href="date.html#9858">[ date ]</a>              <a href="thread.html#9858">[ thread ]</a>              <a href="subject.html#9858">[ subject ]</a>              <a href="author.html#9858">[ author ]</a>         </LI>       </UL><hr><a href="https://lists.swift.org/mailman/listinfo/swift-evolution">More information about the swift-evolutionmailing list</a><br></body></html>';

var notMatch = {
  "_id" : "1A5116CD-1758-40FC-81F1-6CFD4C38158E@apple.com",
  "archiveURL": "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009859.html"
};

const notMatchSource = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><HTML> <HEAD>   <TITLE> [swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens   </TITLE>   <LINK REL="Index" HREF="index.html" >   <LINK REL="made" HREF="mailto:swift-evolution%40swift.org?Subject=Re:%20Re%3A%20%5Bswift-evolution%5D%20%5BGuidelines%2C%0A%20First%20Argument%20Labels%5D%3A%20Prepositions%20inside%20the%20parens&In-Reply-To=%3C62A5DE2B-4089-4F7C-834A-D27E11817244%40apple.com%3E">   <META NAME="robots" CONTENT="index,nofollow">   <style type="text/css">       pre {           white-space: pre-wrap;       /* css-2.1, curent FF, Opera, Safari */           }   </style>   <META http-equiv="Content-Type" content="text/html; charset=utf-8">   <LINK REL="Previous"  HREF="009856.html">   <LINK REL="Next"  HREF="009885.html"> </HEAD> <BODY BGCOLOR="#ffffff">   <H1>[swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens</H1>    <B>Jordan Rose</B>     <A HREF="mailto:swift-evolution%40swift.org?Subject=Re:%20Re%3A%20%5Bswift-evolution%5D%20%5BGuidelines%2C%0A%20First%20Argument%20Labels%5D%3A%20Prepositions%20inside%20the%20parens&In-Reply-To=%3C62A5DE2B-4089-4F7C-834A-D27E11817244%40apple.com%3E"       TITLE="[swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens">jordan_rose at apple.com       </A><BR>    <I>Thu Feb 11 20:32:41 CST 2016</I>    <P><UL>        <LI>Previous message: <A HREF="009856.html">[swift-evolution] [Guidelines,  First Argument Labels]: Prepositions inside the parens</A></li>        <LI>Next message: <A HREF="009885.html">[swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens</A></li>         <LI> <B>Messages sorted by:</B>               <a href="date.html#9859">[ date ]</a>              <a href="thread.html#9859">[ thread ]</a>              <a href="subject.html#9859">[ subject ]</a>              <a href="author.html#9859">[ author ]</a>         </LI>       </UL>    <HR>  <!--beginarticle--><PRE>&gt;<i> On Feb 11, 2016, at 17:41, Dave Abrahams via swift-evolution &lt;<A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">swift-evolution at swift.org</A>&gt; wrote:</I>&gt;<i> </I>&gt;<i> </I>&gt;<i> on Thu Feb 11 2016, Jordan Rose &lt;<A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">swift-evolution at swift.org</A>&gt; wrote:</I>&gt;<i> </I>&gt;&gt;&gt;<i> On Feb 11, 2016, at 16:00, Dave Abrahams via swift-evolution</I>&gt;&gt;&gt;<i> &lt;<A HREF="https://lists.swift.org/mailman/listinfo/swift-evolution">swift-evolution at swift.org</A>&gt; wrote:</I>&gt;&gt;&gt;<i> </I>&gt;&gt;&gt;<i> Doug and I reviewed these, and we don\'t think they work.  The right</I>&gt;&gt;&gt;<i> criterion for cocoa seems to be “pull ‘of’ into the base name unless—as</I>&gt;&gt;&gt;<i> Jordan suggested—it means “having.”  </I>&gt;&gt;&gt;<i> </I>&gt;&gt;&gt;<i> Fortunately that seems to be easily determined.  After looking at all</I>&gt;&gt;&gt;<i> the APIs in Cocoa, “of” in the base name means “having” exactly when it</I>&gt;&gt;&gt;<i> is followed by one of the following words: “type,” “types,” “kind,”</I>&gt;&gt;&gt;<i> “size,” “length,” and maybe “stage” (we\'re trying to analyze</I>&gt;&gt;&gt;<i> removeModifiersOfStage</I>&gt;&gt;&gt;<i> &lt;<A HREF="https://developer.apple.com/library/mac/documentation/SceneKit/Reference/SCNParticleSystem_Class/#//apple_ref/doc/uid/TP40014177-CH1-SW132">https://developer.apple.com/library/mac/documentation/SceneKit/Reference/SCNParticleSystem_Class/#//apple_ref/doc/uid/TP40014177-CH1-SW132</A></I>&gt;&gt;&gt;<i> &lt;<A HREF="https://developer.apple.com/library/mac/documentation/SceneKit/Reference/SCNParticleSystem_Class/#//apple_ref/doc/uid/TP40014177-CH1-SW132">https://developer.apple.com/library/mac/documentation/SceneKit/Reference/SCNParticleSystem_Class/#//apple_ref/doc/uid/TP40014177-CH1-SW132</A>&gt;&gt;</I>&gt;&gt;&gt;<i> to figure out how “of”is being used—assistance welcome).</I>&gt;&gt;<i> </I>&gt;&gt;<i> As usual, I object to hardcoded supposedly-exhaustive lists. I\'d</I>&gt;&gt;<i> rather have people fix these up manually with NS_SWIFT_NAME and such.</I>&gt;<i> </I>&gt;<i> We could “automatically fix them up manually” with NS_SWIFT_NAME and let</I>&gt;<i> the framework owners review the patches, but since we know exactly which</I>&gt;<i> ones work it would be a huge waste to ask each framework owner to find</I>&gt;<i> them on their own.</I>Yes, I\'m fine with that. My point is I don\'t want it added to the automatic translation rules. (I expect to be overruled, again.)&gt;<i> </I>&gt;&gt;<i> Given that the parallel to -removeModifiersOfStage: is</I>&gt;&gt;<i> -addModifierForProperties:atStage:withBlock:, I think the stage is not</I>&gt;&gt;<i> being treated as part of the modifier.</I>&gt;<i> </I>&gt;<i> I don\'t think I understand what you wrote above, sorry.</I>This is in reference to &quot;we\'re trying to analyze -removeModifiersOfStage: to figure out how \'of\' is being used—assistance welcome&quot;. My reading is that it is not an &quot;of&quot; that really means &quot;having&quot;.Jordan</PRE><!--endarticle-->    <HR>    <P><UL>        <!--threads-->  <LI>Previous message: <A HREF="009856.html">[swift-evolution] [Guidelines,  First Argument Labels]: Prepositions inside the parens</A></li> <LI>Next message: <A HREF="009885.html">[swift-evolution] [Guidelines,  First Argument Labels]: Prepositions inside the parens</A></li>         <LI> <B>Messages sorted by:</B>               <a href="date.html#9859">[ date ]</a>              <a href="thread.html#9859">[ thread ]</a>              <a href="subject.html#9859">[ subject ]</a>              <a href="author.html#9859">[ author ]</a>         </LI>       </UL><hr><a href="https://lists.swift.org/mailman/listinfo/swift-evolution">More information about the swift-evolutionmailing list</a><br></body></html>';

var notMatchAnd404 = {
  "_id" : "1A5116CD-1758-40FC-81F1-6CFD4C38158E@apple.com",
  "archiveURL": "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/999999.html"
};

const notMatchAnd404Source = '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN"><html><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL /pipermail/swift-evolution/Week-of-Mon-20160208/999999.html was not found on this server.</p><hr><address>Apache/2.2.15 (Red Hat) Server at lists.swift.org Port 443</address></body></html>';

const invalid = {
  _id: "some-invalid-id@apple.com",
  "archiveURL": "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/999999.html"
};

const noLinkHtml = '<html><body><div>No links here</div></body></html>';
const invalidLinkHtml = '<html><body><a href="http://fooledyou.com">Fooled you</a></body></html>';

describe('id-matches-archive-url', () => {
  // A lot of what we are asserting here is that the correct requests are made and the correct 
  // database queries are executed. This module has no callbacks or return value.

  it('should callback with true and the message id if the page matches', (done) => {
    nock('https://lists.swift.org').get('/pipermail/swift-evolution/Week-of-Mon-20160208/009858.html').reply(200, matchSource);

    idMatchesArchiveURL(match._id, match.archiveURL, function(matches, messageId) {
      expect(matches).to.ok();
      expect(match._id).to.equal(messageId);
      done();
    });
  });


  it('should callback with false and a different message id if the page does not match', (done) => {
    nock('https://lists.swift.org').get('/pipermail/swift-evolution/Week-of-Mon-20160208/009859.html').reply(200, notMatchSource);

    idMatchesArchiveURL(notMatch._id, notMatch.archiveURL, (isMatch, messageId) => {
      expect(isMatch).to.not.be.ok();
      expect(messageId).to.equal('62A5DE2B-4089-4F7C-834A-D27E11817244@apple.com'); // From the page source
      done();
    });
  });

  it('should callback with false and null if the page does not exist', (done) => {
    nock('https://lists.swift.org').get('/pipermail/swift-evolution/Week-of-Mon-20160208/999999.html').reply(404, notMatchAnd404Source);

    idMatchesArchiveURL(notMatchAnd404._id, notMatchAnd404.archiveURL, (isMatch, messageId) => {
      expect(isMatch).to.not.be.ok();
      expect(messageId).to.be(null);
      done();
    });
  });

  it('should callback with false and null if the page does not contain a link', (done) => {
    nock('https://lists.swift.org').get('/pipermail/swift-evolution/Week-of-Mon-20160208/999999.html').reply(200, noLinkHtml);

    idMatchesArchiveURL(invalid._id, invalid.archiveURL, (isMatch, messageId) => {
      expect(isMatch).to.not.be.ok();
      expect(messageId).to.be(null);
      done();
    });
  });

  it('should callback with false and null if the page does not contain a valid message id', (done) => {
    nock('https://lists.swift.org').get('/pipermail/swift-evolution/Week-of-Mon-20160208/999999.html').reply(200, invalidLinkHtml);

    idMatchesArchiveURL(invalid._id, invalid.archiveURL, (isMatch, messageId) => {
      expect(isMatch).to.not.be.ok();
      expect(messageId).to.be(null);
      done();
    });
  });
});
