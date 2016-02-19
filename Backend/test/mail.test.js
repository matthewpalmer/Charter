/**
 * This isn't a real test case (mail.js tries to access the db), but it's a little 
 * sanity check til we flesh everything out.
 */


var parseMessage = require('../mail').parseMessage;

var message = { html: '<div dir="ltr"><div class="gmail_extra"><div class="gmail_quote">On Wed, Feb 10, 2016 at 6:05 PM, Matthew Judge via swift-evolution <span dir="ltr">&lt;<a href="mailto:swift-evolution@swift.org" target="_blank">swift-evolution@swift.org</a>&gt;</span> wrote:<blockquote class="gmail_quote" style="margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1ex"><div><div class="h5">\n&gt; Multiple prepositions before the first argument?<br>\n<br>\n</div></div>Yes, before and including the first argument label. For example (from Jacob&#39;s response):<br>\n<span class=""><br>\ncomparePositionInDecodeOrderWithPosition(of cursor: AVSampleCursor) -&gt; ComparisonResult<br>\n<br>\n</span>Jacob suggests spelling it:<br>\n<br>\ncomparePositionInDecodeOrder(withPositionOf cursor: AVSampleCursor) -&gt; ComparisonResult<br>\n<br>\nI agree that Jacob&#39;s spelling is better, but not enough better to justify additional guidelines about prepositions.<br>\n<div class=""><div class="h5"><br></div></div></blockquote><div><br></div><div>I don&#39;t know enough about linguistics to express this properly, but I suspect there&#39;s something to be said about the &quot;verb phrase&quot; being the part that comes before the paren. To me, &quot;comparePositionInDecodeOrderWithPosition(of:)&quot; is confusing because there is a noun &quot;Position&quot; immediately preceding the parenthesis, which might indicate that the argument should be a position, but in reality the most meaningful part of the method name is the verb, &quot;compare&quot;.</div></div></div></div>\n',
  text: 'On Wed, Feb 10, 2016 at 6:05 PM, Matthew Judge via swift-evolution <\nswift-evolution@swift.org> wrote:\n>\n> > Multiple prepositions before the first argument?\n>\n> Yes, before and including the first argument label. For example (from\n> Jacob\'s response):\n>\n> comparePositionInDecodeOrderWithPosition(of cursor: AVSampleCursor) ->\n> ComparisonResult\n>\n> Jacob suggests spelling it:\n>\n> comparePositionInDecodeOrder(withPositionOf cursor: AVSampleCursor) ->\n> ComparisonResult\n>\n> I agree that Jacob\'s spelling is better, but not enough better to justify\n> additional guidelines about prepositions.\n>\n>\nI don\'t know enough about linguistics to express this properly, but I\nsuspect there\'s something to be said about the "verb phrase" being the part\nthat comes before the paren. To me,\n"comparePositionInDecodeOrderWithPosition(of:)" is confusing because there\nis a noun "Position" immediately preceding the parenthesis, which might\nindicate that the argument should be a position, but in reality the most\nmeaningful part of the method name is the verb, "compare".\n_______________________________________________\nswift-evolution mailing list\nswift-evolution@swift.org\nhttps://lists.swift.org/mailman/listinfo/swift-evolution\n',
  headers: 
   { 'dkim-signature': 'v=1; a=rsa-sha1; c=relaxed; d=swift.org; h=mime-version:in-reply-to:references:to:cc:subject:list-id:list-unsubscribe:list-archive:list-post:list-help:list-subscribe:from:reply-to:content-type:sender; s=s1; bh=B7uv4J7Zn1MxE6i2i6up7JXeRB8=; b=mpBA68SRVJTT2uuc7QQsuAG gTz/NiTHOlbxSRLNaMGtJpXPr29mia23hiSExeUhGxpBmXpymaonv8MzjZ3k5mJi k1VdX/eA/E48a7Lo1SwPyYC9pCVqocpKwrYAODC+yqM1foQkmPVCZNc9jEHlZZYY I94JlBvMRp6jznAyBgeE=',
     received: 
      [ 'by filter0196p1las1.sendgrid.net with SMTP id filter0196p1las1.28911.56BBEF8379 2016-02-11 02:18:43.634561255 +0000 UTC',
        'from swiftmailman01.softlayer.com (fe.46.2da9.ip4.static.sl-reverse.com [169.45.70.254]) by ismtpd0011p1las1.sendgrid.net (SG) with ESMTP id paHq7Ud_Sv6q06VZOkaRRA Thu, 11 Feb 2016 02:18:43.690 +0000 (UTC)',
        'from swiftmailman01.softlayer.com (localhost.localdomain [127.0.0.1]) by swiftmailman01.softlayer.com (Postfix) with ESMTP id AF3D95CE26E; Wed, 10 Feb 2016 20:20:08 -0600 (CST)',
        'from swiftproxy1.softlayer.com (unknown [10.160.30.90]) by swiftmailman01.softlayer.com (Postfix) with ESMTP id 5E4485CE26D for <swift-evolution@swift.org>; Wed, 10 Feb 2016 20:20:07 -0600 (CST)',
        'from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180]) by swiftproxy1.softlayer.com (Postfix) with ESMTP id F11B1A6120 for <swift-evolution@swift.org>; Wed, 10 Feb 2016 20:19:17 -0600 (CST)',
        'by mail-ig0-f180.google.com with SMTP id hb3so26926121igb.0 for <swift-evolution@swift.org>; Wed, 10 Feb 2016 18:18:41 -0800 (PST)',
        'by 10.107.147.196 with HTTP; Wed, 10 Feb 2016 18:17:57 -0800 (PST)' ],
     'x-original-to': 'swift-evolution@swift.org',
     'delivered-to': 'swift-evolution@swift.org',
     'x-google-dkim-signature': 'v=1; a=rsa-sha256; c=relaxed/relaxed; d=1e100.net; s=20130820; h=x-gm-message-state:mime-version:in-reply-to:references:from:date :message-id:subject:to:cc:content-type; bh=OJl/NtA1vyOXJKYx563Fm60AdlSM/Q0Jma8IdD/h9lA=; b=C6WtlfMpPlmMXZqIs/NBlL6+jZxx5R1geDpekXCw74OweOIoSr/CyplbljXL1aGd6c pvBr81DccLUSSTeqV23U8SojZz+rDI69vJWp3TRQX4yXXEVZ3AlwzbFvWJgYVi/kBSz6 6QHdMnChk43LjdxnOJRz/6F0cWhxIuYmYpcbz34KwiBFlW1tGdIzhObxkiRyCfsGRx7S 6GD2u+Lg/hL8lzeDEnlj8ObARqwpjIpQv9+uRI0VUoF+eOMVqcd6ogWhm03dTcjm591i qiod0TzuRjNcixmA8wCd3A8yf/AQi31FU0Go5eg5rPtEvZ5wCNkwygumMLuWXzKJ3DfR yegg==',
     'x-gm-message-state': 'AG10YOSnbECL9iVu79XmXfJ11VuKvoetuBuIXvoxyqtTrorE6jqjjai5FeZ/quY3kWqUQac8tLWz9vbljetkXw==',
     'x-received': 'by 10.50.28.105 with SMTP id a9mr14336411igh.94.1455157116514; Wed, 10 Feb 2016 18:18:36 -0800 (PST)',
     'mime-version': '1.0',
     'in-reply-to': '<970C5B9C-01F2-4315-A41A-1CBD8A4450E9@gmail.com>',
     references: '<m2bn7p3d7b.fsf@apple.com> <CANq73XOJp5iuoYFWwkd3xhMfoWydQLL7224En6B+htC+WrsY0Q@mail.gmail.com> <m28u2s17fr.fsf@eno.apple.com> <970C5B9C-01F2-4315-A41A-1CBD8A4450E9@gmail.com>',
     date: 'Wed, 10 Feb 2016 18:17:57 -0800',
     'message-id': '<CADcs6kP4SiFu1md=Eai0S0hhRwKYP5Ap5rNypi5QXbL5z2aQog@mail.gmail.com>',
     to: 'Matthew Judge <matthew.judge@gmail.com>',
     cc: 'Dave Abrahams <dabrahams@apple.com>, swift-evolution <swift-evolution@swift.org>',
     subject: 'Re: [swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens',
     'x-beenthere': 'swift-evolution@swift.org',
     'x-mailman-version': '2.1.12',
     precedence: 'list',
     'list-id': '"Discussion of the evolution of Swift, including new language features and new APIs." <swift-evolution.swift.org>',
     'list-unsubscribe': '<https://lists.swift.org/mailman/options/swift-evolution>, <mailto:swift-evolution-request@swift.org?subject=unsubscribe>',
     'list-archive': '<https://lists.swift.org/pipermail/swift-evolution/>',
     'list-post': '<mailto:swift-evolution@swift.org>',
     'list-help': '<mailto:swift-evolution-request@swift.org?subject=help>',
     'list-subscribe': '<https://lists.swift.org/mailman/listinfo/swift-evolution>, <mailto:swift-evolution-request@swift.org?subject=subscribe>',
     from: 'Jacob Bandes-Storch via swift-evolution <swift-evolution@swift.org>',
     'reply-to': 'Jacob Bandes-Storch <jtbandes@gmail.com>',
     'content-type': 'multipart/mixed; boundary="===============4111079274961751045=="',
     sender: 'swift-evolution-bounces@swift.org',
     'errors-to': 'swift-evolution-bounces@swift.org',
     'x-sg-eid': '2BcxX5TeK/Njcx2vvrPSHUjV9wj1C+E6R2yjsoaQzTI4Wo3simZy7eBd65ANp5MWnOehlz4J60gnBv Im8vuQvHcCC8oRkBHAcoAysTVVl7Vtj57Ro11Yw+dVIzkO62IYoCi1Z8St7vQAU/hfJvgAVtaDJMaO TCeIeYoYXQHalpwqH7D80ZIk4V9jE9ExmxbrdcOWCg2O9t8Ofrc6R5MiCDgPagpofxS2Er00tm6el2 pS8P5DeVxQbuI6NwWjZbzbQ19no9OMm7SL8EqipWJz3Q==' },
  subject: 'Re: [swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens',
  references: 
   [ 'm2bn7p3d7b.fsf@apple.com',
     'CANq73XOJp5iuoYFWwkd3xhMfoWydQLL7224En6B+htC+WrsY0Q@mail.gmail.com',
     'm28u2s17fr.fsf@eno.apple.com',
     '970C5B9C-01F2-4315-A41A-1CBD8A4450E9@gmail.com' ],
  messageId: 'CADcs6kP4SiFu1md=Eai0S0hhRwKYP5Ap5rNypi5QXbL5z2aQog@mail.gmail.com',
  inReplyTo: [ '970C5B9C-01F2-4315-A41A-1CBD8A4450E9@gmail.com' ],
  priority: 'normal',
  from: 
   [ { address: 'swift-evolution@swift.org',
       name: 'Jacob Bandes-Storch via swift-evolution' } ],
  replyTo: [ { address: 'jtbandes@gmail.com', name: 'Jacob Bandes-Storch' } ],
  to: [ { address: 'matthew.judge@gmail.com', name: 'Matthew Judge' } ],
  cc: 
   [ { address: 'dabrahams@apple.com', name: 'Dave Abrahams' },
     { address: 'swift-evolution@swift.org',
       name: 'swift-evolution' } ],
  date: 'Wed Feb 10 2016 21:17:57 GMT-0500 (EST)',
  receivedDate: 'Wed Feb 10 2016 21:20:08 GMT-0500 (EST)',
  dkim: 'failed',
  spf: 'failed',
  spamScore: 0,
  language: 'english',
  attachments: [],
  envelopeTo: [ { address: 'mail@charter.matthewpalmer.net', args: false } ] };

var parsed = parseMessage(message);

console.log(parsed);
