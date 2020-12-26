---
layout: post
title: Two Applications of Life Experiences
subtitle: Troubleshooting & Persuasion

---

I took an extended break from the software industry. For one of those years, I was an IT guy. For eight of those years, I was a lawyer. I haven't hitherto mentioned this period on my blog, one mercenary goal of which is to enhance my iOS-developer _brand_. But I value the skills I acquired during these years because they remain useful. This post describes two examples.

<!--excerpt-->

{% include image.html
    file="life/Kwaj.jpg"
    alt="Kwajalein Island"
    caption="Kwajalein Island; Credit: US Army"
    source_link=null
    half_width=true
%}

### Troubleshooting

During the early aughts, I worked as a contract IT guy on a US Army [base](https://www.army.mil/article/234658/reagan_test_site_successfully_supports_hypersonic_test) in the Marshall Islands. Although I had been, at that point, a computer enthusiast for nearly twenty years, I had no training as an IT guy. Upon my arrival on the island, I read the book [Upgrading and Repairing PCs](https://www.informit.com/authors/bio/96f57ed8-2faa-4e08-bd72-5dcacd2b103a) cover-to-cover, gleaning useful information about power supplies and crossover cables. Based on feedback from my manager and happy computer users on the island, I believe that I was a successful IT guy. Although Mueller's book contributed to my success, the primary driver was my mastery of troubleshooting, a technique that involves taking a series of actions to find the action, for example replacing a power supply, that cures a symptom of an ailing computer, for example that it won't turn on. The curative action is rarely the first one taken. Instead, the troubleshooter eliminates possible causes of the symptom before discovering the curative action. For example, in the computer-won't-turn-on case, the troubleshooter might try the following:

1. Firmly seat the power cable's plug in the electrical outlet.
2. Plug another device into the outlet to verify that the outlet has power.
3. Try another power cable.
4. Try another power supply. Voilà! The computer turns on.

I recently installed an Eero mesh network in my home. Installation of the Eero Pro base station and three Eero beacons went smoothly. But setting up the fourth beacon in my garage, necessary for our garage-door openers and irrigation system, proved problematic. Because of the distance between the garage and the rest of the network, the garage beacon repeatedly failed to complete setup. So I troubleshot, taking the following actions:

1. Re-attempt setup several times by unplugging and replugging the beacon.
2. Attempt setup on all other outlets in the garage.
3. Open the door to the basement, site of the beacon closest to the garage, in case the door is blocking signal.
4. Move the living-room beacon to an outlet closer to the garage.

None of these action solved the problem. But I had an epiphany. What if setup requires better signal strength than ordinary operation of the beacon? If that were the case, I realized, I could complete setup by _temporarily_ improving signal strength. So I plugged an extension cord into the garage outlet nearest the house, snaked the cord out of the garage towards the house, plugged the beacon into the cord, and attempted setup. Success! But the beacon couldn't live on an extension cord outside my garage, so I unplugged the beacon and plugged it into the garage outlet nearest the house. The beacon remembered its successful setup and rejoined the network. 💪

### Persuasion

I put a _lot_ of work into my first post on this blog, [Converting an App from Interface Builder to Programmatic Layout](https://racecondition.software/blog/programmatic-layout/). 6,221 words! Eight screenshots! Thirty code snippets! In order for this work not to have been wasted, I wanted to persuade readers to read the whole post and potentially share it. My experience as a lawyer helped. Although the art of persuasion is a [vast](https://www.amazon.com/Scalia-Garners-Making-Your-Case-ebook/dp/B002PEP4NW/ref=sr_1_1?crid=1EFD1AA8BTGBH&dchild=1&keywords=making+your+case+the+art+of+persuading+judges&qid=1587331186&sprefix=making+your+case%2Caps%2C204&sr=8-1) [subject](https://www.law.uh.edu/faculty/adjunct/dstevenson/2018Spring/CANONS%20OF%20CONSTRUCTION.pdf) and therefore largely beyond the scope of this post, I provide here two techniques of persuasion that I used in my post on programmatic layout.

1. During the course of my legal-writing [studies](https://www.storytellingforlawyers.com/philip-n-meyer), I became aware of conclusory statements and how to avoid them. A conclusory statement [is](http://livingstingy.blogspot.com/2013/12/conclusory-statements.html) one "made in an argument that states a conclusion, without any foundation, underlying logic, or reasoning". The problem with a conclusory statement is that provides weak support for a conclusion. Indeed, a conclusory statement may be regarded as little more than the arguer's opinion. In the context of my post on programmatic layout, a conclusory statement in support of my argument that the reader should read the whole post might have been something like "You should read this giant post because programmatic layout is better than Interface Builder". The way to avoid conclusory statements is to carefully lay out supporting evidence before stating the conclusion. In my post, I described _seven_ benefits of programmatic layout compared to Interface Builder. Only then did I conclude "that developers who know only [Interface Builder] would benefit from learning" programmatic layout and, by implication, learn programmatic layout by reading the whole post.
2. As a Vermont lawyer, I complied with the [Vermont Rules of Professional Conduct](https://www.vermontjudiciary.org/sites/default/files/documents/VermontRulesofProfessionalConduct.pdf). Rule 3.3(a)(2) states, in part, that "A lawyer shall not knowingly ... fail to disclose to the tribunal legal authority ... known to the lawyer to be directly adverse to the position of the client". My desire not to lose my law license admittedly motivated my compliance with this rule. But there was another motivation: persuasion. By disclosing to the judge contrary legal authority, whether in my written filings or in court, I found that my arguments were more effective. In the course of disclosing contrary legal authority, I could address how it did not prevent the judge from adopting my conclusion. On the contrary, disclosure helped earn the respect of the judge and opposing counsel. I applied Rule 3.3(a)(2) to the programmatic-layout post in the following manner: I described _five_ benefits of Interface Builder compared to programmatic layout, signaling to the reader that I was not an unthinking programmatic-layout partisan. Rather, I facilitated a weighing of the benefits and drawbacks of the two approaches to UI creation, hoping that the reader would see value in programmatic layout, as I do. Seeing value in programmatic layout, the reader would be motivated to read the post.

Did I succeed in persuading readers? By one objective measure, I did: the post ranks second all-time, according to my AWS logs, only to [this one](https://racecondition.software/blog/unit-testing/), even without the help of flamenco dancers or [iOS Dev Weekly](https://iosdevweekly.com/issues/380#code).

### Call to Action

The goal of this post is to inspire you, the reader, to reflect upon the contributions of your life experiences outside software development. Please consider [sharing](https://racecondition.software/contact/) your reflections with me.
