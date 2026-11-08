---
layout: post
title: "Something Rather Than Nothing"
subtitle: "Claude Code, GPT-6 Astra, and a Site Search That Learned to Come Up Empty"
---

You may already be a happy Anthropic customer, but that doesn't mean you shouldn't get an OpenAI subscription. Read on to find out why.

<!--excerpt-->

{% include image.html
    file="siteSearch/mole-spyglass.jpg"
    alt="A glossy 3D cartoon of an anthropomorphic mole on the quarterdeck of an early-nineteenth-century sailing warship at night. He wears a Royal Navy officer’s uniform of about 1805: a black bicorne edged in gold, a navy-blue tailcoat with white cuffs, gilt buttons, and a gold epaulette, a white waistcoat, white breeches, and black boots. Gripping a long brass spyglass in both clawed pink forepaws, he holds it to his eye and aims it up and ahead at a small cluster of six bright blue-white stars beside the Milky Way. A lantern hanging beside him lights him in warm amber, and a brass ship’s bell engraved RACE CONDITION hangs below it. In front of him stand the ship’s wheel and a brass binnacle with a compass, and beyond the rail lies a dark, white-capped sea."
    caption="The mole is Claude Code, which my speech-to-text app heard as <em>clawed code</em>, and a mole sees poorly unaided. The spyglass is a second opinion. The stars are, in Latin, <em>astra</em>. The cluster is the Pleiades, the Seven Sisters, shown with the <a href='https://www.rmg.co.uk/stories/topics/what-are-pleiades'>six</a> that most people can see today. At sea in 1805, under a sky with no light pollution, a keen eye might have counted all seven. A mole’s eye is not keen, which is what the spyglass is for. The ship, according to its bell, is this blog."
%}

On November 8, 2026, [Claude Code](https://code.claude.com/docs/en/overview), running Anthropic's [Opus 5.5](https://www.anthropic.com/news/claude-opus-5-5), replaced the search box on this site. Claude designed the replacement, built it, tested it, and fixed bugs it found. Then I asked GPT-6 Astra, a model from OpenAI, to review the uncommitted changes. Astra found seven genuine problems with Claude's implementation.

My thesis is not that one vendor's model is better than the other's. Claude did most of the work. The thesis is that both models have lacunae, and that a second subscription, from a second vendor, is an inexpensive way to find the places where the first is wrong. What follows is the story of a search box that would rather show something than nothing, of the fix that taught it otherwise, and of the second reviewer that found what the fix had gotten wrong.

## Five Results, None of Them Right

Since the [first commit](https://github.com/vermont42/racecondition.software/commit/4e317e4) of this site's repository, in April 2018, the site has offered a search box. The box was a DuckDuckGo form, adapted from DuckDuckGo's own instructions and from [a post by Stuart Colville](https://muffinresearch.co.uk/adding-a-duckduckgo-search-box-to-your-blog/), and it worked by sending the reader to DuckDuckGo with the query and a hidden field that restricted results to this domain. Here is its [final form](https://github.com/vermont42/racecondition.software/blob/e946255/_includes/search_box.html):

```html
<div class="search">
    <form name="search" action="https://duckduckgo.com/" class="search__form">
        <input type="search" class="search__input" placeholder="Search via DuckDuckGo" name="q">
        <input type="hidden" value="racecondition.software" name="sites">
        <input type="hidden" value="1" name="kh">
        <input type="hidden" value="1" name="kn">
        <input type="hidden" value="1" name="kac">
        <input type="hidden" value="1" name="kc">
        <button class="search__button" type="submit">Search</button>
    </form>
</div>
```

In eight and a half years, I had never used it. On November 8, I did, because I wanted to know whether I had ever written about using Astra. I typed `astra`, and DuckDuckGo returned five pages from this site.

{% include image.html
    file="siteSearch/duckduckgo-astra.png"
    alt="DuckDuckGo search results, in dark mode, for the query astra site:racecondition.software, beneath a notice reading Only showing results from racecondition.software. Five results are listed: Search this site; The Aside That Built a Test Suite, dated July 24, 2026; About; Contact; and the third page of the blog’s post listings, whose snippet describes localizing 65,000 words of app content with seven AI agents. None of the five pages contains the word astra."
    caption="DuckDuckGo’s five results for <em>astra</em>, none of which contains it. The first is this site’s own search page, which at the time contained nothing but a search box."
%}

None of the five contains *astra*. Neither does any other page on the site: the closest thing to *astra* is *astray*, which appears once, in [*Live-Coding Exercises*](https://racecondition.software/blog/live-challenges/). The query therefore had one defensible answer, that post, and one honest answer, nothing. DuckDuckGo gave neither. Restricted to a domain on which no page matched, it returned pages from that domain that had nothing to do with the query.

My message to Claude Code was correspondingly blunt. I wrote that "DuckDuckGo search is [REDACTED]",[^redacted] noted that none of the pages I had checked contained the word, and asked it to "recommend some alternative, more reliable search options".

Claude's diagnosis was broader than my complaint. The `astra` results, it observed, were a symptom, and the underlying defects were structural. DuckDuckGo [largely sources](https://duckduckgo.com/duckduckgo-help-pages/results/sources/) its traditional web results from Bing, so a new post can be missing from them for weeks; nothing guarantees that a result contains the query; and the reader leaves this site to read a third party's page of results. The second defect is the worst. A search that admits it found nothing tells the reader something true. A search that is confidently wrong tells the reader something false about the site, and the reader has no way to know.

## Choosing a Replacement

The site's architecture constrained the choice. This site has no front-end dependencies: no Bootstrap, no jQuery, and no Font Awesome. Its CSS is hand-written, its JavaScript lives inline in a single include, and until November its only build step was Jekyll. At the time, it held 42 posts, about 900 KB of Markdown, and 47 pages worth indexing.

Claude recommended a hand-rolled index. Jekyll would emit a JSON file containing the title, URL, date, and plain text of every post, and a few dozen lines of inline JavaScript would fetch the file and match words exactly. The case for it was fit: no dependencies, no new build step, and matching that is exact and predictable. Its costs were a few hundred kilobytes for the search page to download, no stemming, and naive ranking. Claude dismissed the hosted services and the search libraries quickly, and I agreed with the dismissals.[^hosted]

I chose [Pagefind](https://pagefind.app) instead. Pagefind is a program, written in Rust, that runs after a static site is built. It indexes the generated HTML and writes into the site a chunked index and a small JavaScript-and-WebAssembly runtime, so that a reader's browser downloads only the chunks of the index that a query touches. It ranks results with a BM25-style score, stems words so that `testing` finds *tested*, and highlights matches in excerpts. Its costs were a new build step and a pinned dependency, in CI and in local development.[^pin]

I think the trade is defensible. Pagefind is a build-time tool rather than a library that the site vendors, and the `pagefind.js` file that a reader's browser loads is generated alongside the index it reads, so the two cannot drift apart. But I owe Claude's recommendation a concession that I could not have made at the time. An index that matched words exactly would have been incapable of the failure that the rest of this post is about, because it could not have returned a page that lacked the query. Nearly everything that went wrong from here on went wrong in machinery that my choice required.

Claude built the results page on Pagefind's headless API rather than on its prebuilt interface, which would have imported someone else's CSS into a site whose CSS is otherwise hand-written.[^ui] Posts and standalone pages are indexed through Pagefind's [`data-pagefind-body`](https://pagefind.app/docs/indexing/#limiting-what-sections-of-a-page-are-indexed) attribute, which, once it appears anywhere on a site, excludes every page that lacks it. That keeps the paginated listings, the header, and the footer out of the results.

## Pagefind Does It Too

Pagefind's first answers looked right. `astra` returned one page, *Live-Coding Exercises*, with *astray* highlighted, because Pagefind treats each query word as a prefix. Then Claude did the thing that made the rest of this post possible. Instead of confirming that words on the site could be found, it searched for words that were not on the site, to see whether Pagefind would say so.[^failure]

Pagefind would not say so.

<div class="table-responsive" markdown="1">

| Query | Results | What the results contained |
|---|---|---|
| `astrb` | 44 | *as* |
| `kubernetes` | 1 | a lone *K* |
| `django` | 2 | *D.* and *%d* |
| `zebra` | 1 | a lone *z* |
| `xyzzyqq` | 1 | `<x>,<y>:`, in a code sample |
| `swiftuix` | many | *SwiftUI* |
| `blockchain` | 12 | *block* and *Blocks* |

</div>

The mechanism is in Pagefind's source. When no indexed word begins with a query word, a function named [`find_word_extensions`](https://github.com/CloudCannon/pagefind/blob/v1.5.2/pagefind_web/src/search.rs#L811-L838) logs "No word extensions found, checking the inverse" and searches instead for the longest indexed word with which the query word begins. For `kubernetes`, on this site, that word is *k*. Pagefind scores such matches low, but the results page shows no scores, so to a reader they look exactly like DuckDuckGo's: confident results that do not contain the query.

The two tools, in other words, had made the same product decision: each would rather return something than nothing. [Leibniz](https://en.wikipedia.org/wiki/Why_is_there_anything_at_all%3F) asked why there is something rather than nothing, and justified the question in his next sentence: "Car le rien est plus simple et plus facile que quelque chose", for nothing is simpler and easier than something.[^leibniz] For a search engine, nothing is neither simpler nor easier, as the rest of this post demonstrates at some length. On a large site, falling back to something is a reasonable way to forgive typos. On a small personal blog, where "this blog has never mentioned Kubernetes" is a true and useful answer, it is a way of being confidently wrong.

### The First Fix

Pagefind has an exact mode, which it uses when a query is wrapped in double quotes, and exact mode never checks the inverse. Pagefind's source [says so](https://github.com/CloudCannon/pagefind/blob/v1.5.2/pagefind_web/src/search.rs#L244-L247) in a comment: "If we can't find this word, there are obviously no exact matches". Claude's probing confirmed it: `"kubernetes"` and `"astrb"` find nothing. Exact mode still stems, so `"testing"` and `"test"` find the same 33 pages, and it still ignores case and diacritics, so `"etre"` finds *être*. But it does not treat words as prefixes, so `"astra"` finds nothing, and it treats several words as a phrase. Exact mode was the right check and the wrong search.

So Claude made it a check. Before running a query, the search page validated each word. A word counted as present if an exact search found it, or, failing that, if the top result of an ordinary search highlighted a word that began with it. The first test preserved stemming. The second preserved prefix matching, so `astra` passed on the strength of *astray*, and `kubernetes` failed, because *K* does not begin with *kubernetes*. If any word failed, the page reported no results, and for a query of several words, it named the culprit: *No results for "swift kubernetes". Nothing on this site contains "kubernetes".* If every word passed, the ordinary, better-ranked search ran.

The fix passed every test in Claude's battery. The absent words found nothing. `astra` found its one page, and `SwiftUI`, `testing`, `trailing closures`, `dependency injection`, `être`, `CLAUDE.md`, `async/await`, and `xcbeautify` found theirs. Before committing the change, I asked for a second opinion.[^uncommitted]

## A Second Opinion from a Second Vendor

I pay OpenAI $20 a month for a subscription that includes Codex, its coding agent, and I used Codex to ask Astra to review the uncommitted changes. My prompt quoted my original message to Claude and then said this:

> We discussed alternatives, and the result was the unstaged changes you see. Please review these changes for bugs, code smells, gaps, or inefficiencies.

That was the whole prompt. It said nothing about Pagefind's fallback, about the validator, or about what Claude had tested.

Astra's report described its findings as "six P2 issues worth fixing and one P3 verification gap". All seven held up. Claude did not accept them on Astra's authority: before changing anything, it reproduced each finding, either in the browser or by reading Pagefind's generated runtime, and then recommended fixing all seven, which I approved.

The two most important findings were in the fix itself.

**`C#` returned 46 results.** This site does not mention C#. The validator accepted it anyway. Pagefind [strips most punctuation](https://pagefind.app/docs/indexing/#indexing-special-characters) from words unless told otherwise, in a query as in a page, and exact mode is no exception, so the exact search for `"C#"` was a search for *c*, which is everywhere. The leading result was [*What Belongs in CLAUDE.md*](https://racecondition.software/blog/claude-md-size/), with *CLAUDE.md* and *Characters* highlighted. Astra put it precisely: "This reproduces the original complaint: plausible-looking results for a term absent from the site." The fix for one tool's false positives had false positives of its own.

**`existin` returned nothing.** It is a prefix of *existing*, which appears on 13 pages. But the ordinary search's top excerpt highlighted *exist*, a stemmed match, and the validator, which looked only at the top excerpt, concluded that no word on the site began with `existin`. The third result's excerpt highlighted *existing*; the validator never looked at it. `runnin` failed the same way, because the top excerpt highlighted *Long-Running*, which, with its hyphen folded away, does not begin with `runnin`. When Claude reproduced this finding, it turned out to be worse than Astra had reported. The search page updates as the reader types, so every reader who typed *existing* watched "No results" appear at `existi` and again at `existin`, a false negative scheduled to occur in the middle of nearly every search for the word. The fix for one tool's false positives had false negatives, too.

The other five findings concerned what happens when something goes wrong, a part of any program that a test of the happy path never visits.

<div class="table-responsive" markdown="1">

| # | Finding | Resolution |
|---|---|---|
| 3 | A deploy deletes index files that an already-open search page still expects | After any failed load, restart Pagefind once, which rereads its entry file and learns the new filenames |
| 4 | Two quick clicks on "More results" append the same ten results twice | Disable the button the moment it is clicked, and drop duplicate results |
| 5 | A failed "More results" load goes unhandled, so the button just seems dead | Catch the failure, offer to try again, and keep the results already shown |
| 6 | One failed fetch poisons that piece of the index for the rest of the visit | The same restart, coordinated so that simultaneous failures restart only once |
| 7 | Matching page counts do not prove that the index is current | Fail verification when the index is older than any page it covers |

</div>

Finding 6 is the one I admire most. Astra established it by loading Pagefind's generated runtime under Node, making the first fetch of a result fragment fail, restoring the network, and searching again. The second attempt failed with the original error, and the fetch count stayed at one: Pagefind had cached the failure and never asked the server again.[^cache] Finding 3 Claude judged real but rare, since the site had been deployed three times since August, and it fixed that one in the browser rather than with the server-side retention scheme that Astra had suggested.[^deploys]

How Astra worked matters to the argument that follows, and I will describe the approach. Astra built the site in a temporary directory, ran the pinned index build, and ran the site's verification script. It exercised the generated JavaScript and WebAssembly runtime under Node, ran the validator extracted from the page, and drove the page's real rendering functions in a minimal DOM harness, with data that it could delay or reject at will. It simulated a deploy by changing an article and rebuilding the index beneath a search that was still using the old one. What it could not do was use a browser: its sandbox could not reach a browser host, and its report says plainly that layout and in-browser behavior "remain unverified". Claude's testing, then and afterward, ran through a browser, as a reader's would.

## A List of Everything

Findings 1 and 2 shared a root. The first fix had treated as a dictionary two things that were not one: an exact search that silently discarded punctuation, and a single excerpt chosen for display rather than for completeness. The second fix builds an actual dictionary.

After Pagefind indexes the site, a short Ruby script, [`build_search_words.rb`](https://github.com/vermont42/racecondition.software/blob/562a5b7/scripts/build_search_words.rb), reads Pagefind's own fragments, which hold the text that Pagefind actually indexed, and writes every distinct word to a file called `site-words.json`. Reading the fragments rather than the HTML means that the list cannot drift from the index. Each word goes into the list whole and also split at its punctuation, because Pagefind indexes both forms, so that *long-running* is findable as `longrunning`, as `long`, and as `running`. And any word that begins another word is dropped, since the page asks only whether some word begins with the query word. That turns 12,454 distinct words into 9,104, about 37 KB as the CDN compresses them. Pagefind now [keeps](https://pagefind.app/docs/config-options/#include-characters) `#` and `+` as parts of words, so that `C++` and `C#` are indexed as themselves, and the word list folds words the same way.[^chars]

The check that replaced the excerpt test is short enough to quote whole, from [`foot.html`](https://github.com/vermont42/racecondition.software/blob/562a5b7/_includes/foot.html):

```js
var isOnSite = function(search, word) {
    var folded = search.fold(word);
    if (!folded) return Promise.resolve(true);
    for (var i = 0; i < search.words.length; i++) {
        if (search.words[i].lastIndexOf(folded, 0) === 0) return Promise.resolve(true);
    }
    if (!/^[\p{L}\p{N}]+$/u.test(folded)) return Promise.resolve(false);
    return search.pagefind.search('"' + folded + '"').then(function(exact) {
        return exact.results.length > 0;
    });
};
```

A query word passes if some word in the list begins with it, which keeps prefix matching: `existin` finds *existing*. Failing that, a word made only of letters and digits passes if exact mode finds it, which keeps stemming: `refusing`, a word this site had never used, finds [*When Refusals Don't Translate*](https://racecondition.software/blog/when-refusals-dont-translate/).[^refusing] A word containing punctuation gets no second chance, because exact mode would strip the punctuation and find whatever remained, which is how `C#` became *c*.

Leibniz thought nothing simpler than something. For a search box, nothing is the hardest answer to give, because it is a claim about everything: to say that no page contains a word, the search must know every word on every page. `site-words.json` is that knowledge, 9,104 words of it.

Claude then tested the second fix, and this time the testing included the failure paths. It ran 38 queries in the browser, including every case from Astra's review, and then broke the site on purpose. It rebuilt the index beneath an open results page to simulate a deploy, moved the index's fragments away to simulate an outage and then restored them, clicked "More results" twice in the same instant, and rebuilt pages after indexing to confirm that verification now fails on a stale index. Everything behaved. The result shipped as [`562a5b7`](https://github.com/vermont42/racecondition.software/commit/562a5b7).

## How It Searches Now

At my request, Claude measured the deployed search on November 8, before this post existed to change the results.[^measured] The standard was strict. For each query, the correct set of pages was computed from the text that Pagefind had indexed: a page belonged in the set if every query word began some word on the page. That standard gives no credit for stemming, so `tested` finding pages that say only *testing* counts against the search.

<div class="table-responsive" markdown="1">

| Measure | Result |
|---|---|
| Queries for words on the site that returned exactly the right pages | 43 of 58 |
| Queries for words on the site that found every right page | 56 of 58 |
| Queries for words not on the site that returned nothing | 12 of 13 |
| Results containing neither the query nor a word sharing its stem | none observed |

</div>

I checked `astra` myself.

{% include image.html
    file="siteSearch/pagefind-astra.png"
    alt="The new search page on racecondition.software, in dark mode. Under the site’s header and the heading Search this site, the search box contains astra, and a status line reads 1 result for astra. The single result is Live-Coding Exercises, dated 08 May 2025, with an excerpt in which the word astray is highlighted: this invitation can lead a candidate astray in that a candidate might waste precious minutes perusing unhelpful or irrelevant search results."
    caption="One result for <em>astra</em>, and it contains a word that begins with the query. The passage warns that a candidate can be led astray by “unhelpful or irrelevant search results”, a description of my old search box written eighteen months before I discovered that it applied."
%}

The misses are trades rather than bugs, and each deserves a sentence or two.

**Stemming over-matches technical terms.** `Combine` finds *combined* and *combination*, which is noise to a reader who means Apple's framework, and `accessibility` returns 26 pages, of which nine contain the word, because Pagefind's English stemmer reduces the word to *access*. Pagefind offers no way to turn stemming off for a single query, and exact mode stems too. This is the price of `tested` finding *testing*, and I am inclined to pay it.

**The one absent word that returns results is a misspelling.** `dependancy` returns 24 pages, because the stemmer reduces *dependancy*, *dependency*, and *depend* to a single stem, and exact mode therefore accepts it. None of the 24 pages contains the misspelling, and all of them are about what the misspeller meant. I am content to call that accidental spelling correction.

**Typing a long word can dip in the middle.** Pagefind stores stems, so *accessible* and *accessibility* are both indexed as *access*. A reader typing the word sees 26 results at `access`, 3 at `accessib`, and 26 again at `accessibility`, because `accessib` begins words on the page but does not begin the stem in the index.

None of this costs the reader much time. Once Pagefind has loaded, a query for an absent word is answered in six or seven milliseconds, and a query for a present word in 7 to 150, most of that spent fetching the first ten results. A reader's first search downloads about 145 KB, half of it Pagefind's WebAssembly and a quarter of it the word list, plus the slices of the index that the query touches.

In fairness to DuckDuckGo, Claude ran thirteen of the same queries through it the same day. On distinctive words in post titles, DuckDuckGo did well: its top results for `SwiftUI` and for `dependency injection` were the right posts. It returned nothing for `kubernetes`, `zebra`, and `C#`, which is more than Pagefind managed out of the box. Its characteristic failure was padding. It filled its ten slots with the home page, the archive, the About page, and, above all, this site's own search page, which appeared for nearly every query.[^noindex] Asked for `Zappa`, who appears in one post, [*Dependency Injection for Testability*](https://racecondition.software/blog/unit-testing/), DuckDuckGo's top four results were the home page, the search page, the archive, and the home page again. The new search returns the one post.

## Why Pay Both

Here, then, is the argument that the first sentence of this post promised.

It is not that Astra is a better programmer than Claude, or a better reviewer. Claude found the defect that justified the whole project, by searching for words that were not on the site. It built the fix and the fix's replacement. It verified each of Astra's findings before acting on it and found one of them worse than reported. It did the browser testing that Astra could not immediately do, as well as the production measurement. All seven of Astra's findings were real, which is to Astra's credit, and all seven were in code that Claude had written and tested, which is not to Claude's discredit, because that is what review is for.

The argument is that a second reviewer adds value in proportion to the independence of its errors from the first reviewer's, and that a model from a second vendor is an inexpensive source of independence.

I have measured the alternative. In [*Maximum Effort, Measured*](https://racecondition.software/blog/effort/), two of three runs of the same model confidently asserted the same falsehood about Dynamic Type, and a majority vote would have ratified it. In [*The Fable and the Opus*](https://racecondition.software/blog/fable-and-opus/), two reports by the same model made the same arithmetic slip, and I concluded that "a union of same-model runs inherits the model's correlated errors". Running one model twice buys coverage, but it does not buy independence, because the second run shares the first run's training, its habits, and its blind spots.

Here the mechanism was visible. Claude's test battery was written by the same mind that wrote the validator, and it tested the validator's assumptions while sharing them. The validator assumed that an exact search for a word searches for that word. In Claude's battery, the one absent word containing punctuation was `@MainActor`, and stripping its `@` leaves *mainactor*, which is not on the site either, so the assumption survived its test by luck. The validator also assumed that the top excerpt would show a word beginning with any prefix that was genuinely on the site. The prefix in the battery that most plainly depended on that assumption was `astra`, and `astra` could hardly fail, since exactly one page contains a word beginning with it. Astra had made neither assumption, so it had none to share. It read the validator, asked what each test actually established, and tried `C#` and `existin`, which are the inputs at which the assumptions break.

The tools mattered as well. Claude, with a browser, tested what a reader would see. Astra, without one, tested what the code does, and a harness in which promises can be delayed or rejected at will makes failure the natural thing to test. Astra's other five findings concerned deploys, double clicks, failed fetches, and stale indexes, conditions that none of Claude's tests had produced.

And there is distance. In [*What an AI Code Review Actually Finds*](https://racecondition.software/blog/ai-code-review/), I wrote that reviewing your own code is hard not because you lack the skill "but because you lack the distance": knowing what the code is supposed to do inoculates you against noticing what it actually does. A model reviewing its own work in its own session has the same problem, and any fresh reviewer solves it.

Which brings me to what this episode cannot show. It is one review of one change. I did not ask a fresh Claude session to review the same changes, and I cannot now, because the state that Astra reviewed was never committed. So I cannot separate the value of a different vendor from the value of a fresh reviewer, and some of these seven findings might well have been made by a new Claude session given the same brief. What the evidence supports is narrower, and I think it is enough. Any fresh reviewer brings distance. A reviewer from another vendor brings distance plus different training, different habits, and different tools, and therefore errors less likely to coincide with the first model's. Unioning buys coverage, verification buys correctness, and a second vendor buys a measure of independence. Mine costs $20 a month.

The workflow is easy to repeat. Claude Code builds and tests. GPT-6 Astra reviews the uncommitted changes, with a brief that tells it nothing in particular to look for. Claude verifies each finding before fixing anything, because a reviewer's confidence is not evidence. And I decide.

## The Same Argument, in Pictures

The argument is not peculiar to code. Here is a photograph of a cat,[^redaction] and here are the images that GPT Image and Gemini Image each made from it, given the same prompt.[^prompt]

{% include image.html
    file="siteSearch/cat-photo.jpg"
    alt="A photograph of a lilac Burmese-type cat with huge pale green eyes, sitting upright on a white shelf above a copy of Frog and Toad All Year and staring at the camera with a startled expression. She wears a grey collar with a round AirTag holder and a brass tag. On the wall behind her hang a medal on a red, white, and blue ribbon, a teal card quoting Psalm 139:1, and a handwritten note whose seven lines are covered by black redaction bars."
    caption="The photograph. The note on the wall names people who did not ask to appear in a blog post, so GPT Image redacted it, and Claude, checking GPT Image’s work, removed the traces of handwriting left between the bars. The reviewing runs in both directions."
    half_width=true
%}

{% include image.html
    file="siteSearch/cat-gpt-image.jpg"
    alt="A photorealistic, cinematic scene inside a cluttered lunar base. A giant, fluffy, tawny version of the cat, with wide aqua eyes and a glowing AirTag on her collar, swats with bared claws at a purple, many-eyed, tentacled alien covered in cat hair. Astronauts react: one hugs a tentacle, one kneels offering a can of tuna, one lint-rolls the alien, and one holds a clipboard reading INCIDENT REPORT #47, CAT AGAIN. Signs read WARNING: GRAVITY ANOMALY (CAT), DAYS WITHOUT INCIDENT: 0, and AIRLOCK B. A rubber duck in a space helmet floats past, lockers lie toppled like dominoes, a flattened box reads MOON ROCKS, DO NOT SIT, and through the window, paw prints lead across the Moon to a cat-shaped hole patched with duct tape, beneath the Earth."
    caption="GPT Image’s version. Every sign that the prompt spelled out is spelled correctly, the rubber duck has a helmet, and the cat has acquired a more luxuriant coat than she owns."
%}

{% include image.html
    file="siteSearch/cat-gemini-image.jpg"
    alt="A photorealistic scene inside a white lunar base. A giant grey-eared cat with pale green eyes, closely resembling the cat in the photograph, raises one paw and rests the other on the head of a green-and-purple, three-eyed, tentacled alien. An astronaut riding a tentacle aims a laser at the alien, another lint-rolls its face, another kneels with a can, another films on a phone, another holds a clipboard reading INCIDENT REPORT #47, CAT AGAIN, and a mission commander covers his face. A screen reads WARNING: GRAVITY ANOMALY (CAT), a cat-shaped sign taped to the wall reads DAYS WITHOUT INCIDENT: 0, a wall sign reads AIRLOCK COMMANARE B, a cat bed burns in a corner, and a box reads MOON ROCKS, DO NOT SIT. Through the window, paw prints cross the Moon beneath the Earth."
    caption="Gemini Image’s version. The likeness is closer and the lettering looser, and the ID tag that the prompt asked to leave blank has been engraved anyway."
%}

Both images are great. They are not great in the same ways, and the ways in which each falls short of the prompt hardly overlap.

GPT Image rendered all seven pieces of text that the prompt quoted, correctly and legibly, and it found room for nearly every sight gag that the prompt requested: the white surrender flag, the rubber duck in its own helmet, the lockers knocked over like dominoes, and the box of moon rocks flattened where the cat had sat. Gemini Image left out all four. It gave the laser pointer to an astronaut instead of to the alien, engraved the tag that the prompt asked to leave blank, and lettered its HANG IN THERE poster in something close to English. But Gemini Image's cat is the one I would recognize: short-coated, with the lavender-grey ears and muzzle that the prompt asked for, where GPT Image's is a fluffier, tawnier relative. And Gemini Image, unlike GPT Image, rendered the astronaut filming everything on a phone.

Even their misreadings differ. The prompt asked for paw prints leading "straight to a cat-shaped hole in the base's outer wall, patched with duct tape". GPT Image put the duct-taped, cat-shaped hole in the surface of the Moon. Gemini Image turned it into the DAYS WITHOUT INCIDENT sign, which is cat-shaped and duct-taped to the wall.

The errors are not perfectly independent, which is worth knowing too. The prompt never asked either model to label the mission commander. Both did, and both misspelled COMMANDER: Gemini Image's wall sign reads AIRLOCK COMMANARE B, and GPT Image's console label misspells the word differently. A second vendor reduces correlated error. It does not abolish it, which is why the workflow above ends with verification rather than with a vote.

## Astra, Again

Once this post is published and indexed, a search of this site for `astra` will return two pages: *Live-Coding Exercises*, for *astray*, and this one. Both contain a word that begins with the query. DuckDuckGo returned five pages, and none of them did.[^two]

Leibniz held that nothing happens without a sufficient reason. My search box now holds itself to the same standard. It shows a page only when the site's own list of words gives it a reason to, and otherwise it shows nothing, and says so.

## Endnotes

[^redacted]: Redacted for publication by its author. The comparison later in this post suggests that the unredacted words were unfair to DuckDuckGo, at least for distinctive words in post titles.

[^hosted]: Google's Programmable Search shares the old box's dependence on a crawler and adds advertising. Algolia would have brought an account and API keys to a site of 42 posts. Lunr.js would have done roughly what the hand-rolled index did while adding a dependency, and it is largely unmaintained.

[^pin]: Claude pinned [Pagefind 1.5.2](https://github.com/CloudCannon/pagefind/releases/tag/v1.5.2), released in April, rather than [1.6.0](https://github.com/CloudCannon/pagefind/releases/tag/v1.6.0), which had been out for a week, on the principle that a build tool's newest release should first have a chance to break other people's builds. The version appears in exactly one place, [`build_search_index.sh`](https://github.com/vermont42/racecondition.software/blob/562a5b7/scripts/build_search_index.sh), which both CI workflows run between the Jekyll build and verification.

[^ui]: Pagefind ships a prebuilt search interface, with its own JavaScript and CSS, which the results page could have adopted in a few lines. Instead, the inline script in the site's footer imports `pagefind.js`, calls its `search` function, and renders results in the site's own typography: Playfair headings, an Inter meta line, and sage highlights that work in both themes. It shows ten results at a time and keeps the query in the address bar, so that results are linkable.

[^failure]: This is a cousin of the habit I argued for in [*Trust, Then Verify*](https://racecondition.software/blog/ios-build-verify/), and of the one I described in [*The Aside That Built a Test Suite*](https://racecondition.software/blog/the-aside-that-built-a-test-suite/), where every check in a new checker was deliberately broken to confirm that it could fail. Here the rule is to test for the failure that got the last tool fired. A battery of words known to be on the site would have passed every time.

[^leibniz]: Leibniz, [*Principes de la nature et de la grâce, fondés en raison*](https://fr.wikisource.org/wiki/Principes_de_la_nature_et_de_la_gr%C3%A2ce_fond%C3%A9s_en_raison), §7, written in 1714 and published in 1718. The question in full is "Pourquoi il y a plutôt quelque chose que rien ?", and the translations are mine. Leibniz poses it immediately after invoking the principle of sufficient reason, that nothing happens without a reason, to which I return at the end of this post. The space before the question mark is French typography, and I have kept it, as a French reader would expect and as no American copy editor would allow.

[^uncommitted]: The first fix was never committed. It existed only in my working tree, which is where Astra reviewed it, and the [commit that shipped](https://github.com/vermont42/racecondition.software/commit/562a5b7) contains only the code that replaced it. I describe the first fix from Claude's notes rather than link to it.

[^cache]: Claude confirmed the mechanism in Pagefind 1.5.2's generated runtime, which caches each fragment's loading promise by the fragment's hash and keeps the promise whether it resolved or rejected. Pagefind's documentation describes [destroying and reinitializing](https://pagefind.app/docs/api/#re-initializing-the-search-api) the search API, which is what the fix does, once, after any failed load.

[^deploys]: Astra suggested keeping the previous generation of index files on the server for a grace period, or publishing each generation to its own versioned directory. Either would work. For a site deployed three times in three months, Claude judged the machinery not worth it, and I agreed: the client-side restart recovers without the reader noticing, and if the restart fails too, the page says so rather than going quiet.

[^chars]: The set of kept characters is defined once, in [`build_search_index.sh`](https://github.com/vermont42/racecondition.software/blob/562a5b7/scripts/build_search_index.sh), which passes it to Pagefind and to the word-list script. The script records the set in `site-words.json`, and the search page builds its own folding from the file. Keeping the two characters cost nothing observable: Pagefind still indexes the bare part of a word, so `Pedometer` finds *Pedometer++*, and `C++` went from six results to the three pages that mention it.

[^measured]: The ground truth came from Pagefind's 47 indexed fragments, read from a local build of the same commit. The live results came from the production search page, driven through its real search box in Chrome and read back through the same Pagefind instance. I checked `astra` myself; the other 70 queries are Claude's. The DuckDuckGo comparison used DuckDuckGo's HTML interface with `site:racecondition.software`.

[^noindex]: This site's search page had been indexed by Bing, and through Bing by DuckDuckGo, and it ranked for nearly everything, perhaps because a page consisting of a search box is in some sense about every query. It is now marked `noindex` and left out of the sitemap, as search-results pages conventionally are ([`eaf45ae`](https://github.com/vermont42/racecondition.software/commit/eaf45ae)). Search engines will drop it on their next crawl, so the comparison above reflects the site before the change.

[^redaction]: GPT Image's first attempt, given a mask covering only the note, blacked out the whole note as a single block and, ignoring the mask, also redacted a second sheet of paper that I had not asked it to touch. Its second attempt, unmasked, drew one bar per line of handwriting, but a contrast stretch showed fragments of letters between the bars. Claude removed them with a morphological filter, a step that erases strokes thinner than the bars, and composited the note back into the untouched photograph.

[^prompt]: Here is the prompt, verbatim; both models received it with the photograph:

    > Using the attached photo as the reference for the cat, create a hilarious, cinematic sci-fi action scene. Keep the cat instantly recognizable: a lilac Burmese-type cat with a round face, soft lavender-grey ears and muzzle, a cream-colored chest and body, and huge pale aqua-green eyes with a wide, startled, intensely focused expression. Keep her grey silicone collar with the round AirTag holder and the round brass ID tag (leave the tag blank, no text or numbers). The AirTag holder glows softly, and a tiny holographic map floating beside it shows a pin labeled "THE MOON."<br><br>
    > SCALE AND ACTION: The cat is kaiju-sized, about three stories tall, wedged into a cramped lunar base. Her head bends the ceiling panels upward, one ear pokes through a ventilation hatch, and her whiskers have snagged a dangling cable that sparks. She is mid-battle with a slimy purple-green tentacled alien with too many googly eyes, all of which look nervous. The cat swats at it with one enormous paw, claws out, wearing the exact same wide-eyed stare from the photo, as if she has just spotted a bug on the wall. Her other paw pins a tentacle to the floor like a toy mouse. Her tail is puffed up to twice its normal size and has knocked a row of lockers over like dominoes.<br><br>
    > THE ALIEN: One tentacle is desperately holding a laser pointer, aiming a red dot on the wall to distract her, and it's half working: one of her eyes is tracking the dot. Another tentacle is waving a tiny white surrender flag. A third is clutching a "HANG IN THERE" kitten poster torn from the wall. The alien is mid-sneeze, covered in cat hair.<br><br>
    > ASTRONAUTS: Tiny astronauts in white spacesuits react in panic and absurdity. One clings to a tentacle, helmet askew. One kneels and offers an open can of tuna like a peace treaty. One is frantically using a lint roller on the alien. One is filming everything on a phone. One holds a clipboard titled "INCIDENT REPORT #47 — CAT AGAIN." A mission commander in the background has his face in his hands.<br><br>
    > SETTING DETAILS: A retro-futuristic Moon base with white modular panels, flashing red alarm lights, and a digital screen reading "WARNING: GRAVITY ANOMALY (CAT)." A knocked-over sign reads "AIRLOCK B." A wall poster reads "DAYS WITHOUT INCIDENT: 0." A cardboard box labeled "MOON ROCKS — DO NOT SIT" has been flattened where the cat clearly already sat. Floating debris drifts in the low gravity: wrenches, a coffee mug, freeze-dried food packets, a feather toy, and a few tufts of cat fur. Her brown faux-fur cat bed from the original photo sits in a corner, comically small next to her, scorched by a stray laser blast. A rubber ducky in an astronaut helmet floats past.<br><br>
    > BACKGROUND: A large panoramic window shows the grey cratered lunar surface, with giant paw prints leading across the regolith straight to a cat-shaped hole in the base's outer wall, patched with duct tape. Earth hangs in the black starry sky.<br><br>
    > STYLE: Photorealistic with blockbuster movie-poster drama, dramatic low-angle shot looking up at the giant cat, rim lighting from the red alarms, crisp detail on fur texture and her glowing aqua eyes, playful comedic tone where every corner has a sight gag. 3:2 landscape.

[^refusing]: Until this sentence, that is. Once this post is indexed, `refusing` will pass the first test instead of the second, because this post contains it.

[^two]: I checked this by building the site locally with this post included and searching for `astra`. The search returned exactly two pages, and it highlighted *Astra*, *astra*, and *astray* in this one and *astray* in the other.
