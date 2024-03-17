// Used to collect sidebar sidenotes.
#let sidenotes = state("sidenotes", ())

#let heiti = ("Times New Roman", "Source Han Sans SC", "Source Han Sans TC", "New Computer Modern", "New Computer Modern Math")
#let songti = ("Times New Roman", "Source Han Serif SC", "Source Han Serif TC", "New Computer Modern", "New Computer Modern Math")
#let zhongsong = ("Times New Roman","STZhongsong", "SimSun", "New Computer Modern")

#let absy = state("absy", 0in)

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "Hexo Typst", authors: (), body, pagewidth: 0pt) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)

  // Configure pages. The background parameter is used to
  // add the right background to the pages.
  set page(
    numbering: "1", number-align: center,
    height: auto,
    margin: (top: 20pt, rest: 0pt),
    width: pagewidth,
  )

  set text(font: songti, lang: "en", size: 14pt) // "#d9d9e3"
  show math.equation: set text(weight: 400)

  // code block setting
  show raw: it => {
    if it.block {
      rect(
        width: 100%,
        inset: (x: 4pt, y: 5pt),
        radius: 4pt,
        fill: rgb(239, 241, 243),
        [
          // set text(inner-color)
          #place(right, text(luma(110), it.lang))
          #it
        ],
      )
    } else {
      it
    }
  }

  locate((loc) => {
    absy.update(it => loc.position().at("y"))
  })

  // The document is split in two with a grid. A left column for the main
  // flow and a right column for the sidebar sidenotes.
  let sidebar-width = 5.8cm - 1.6cm - 18pt
  grid(
    columns: (1fr, sidebar-width),
    column-gutter: 36pt,
    row-gutter: 32pt,

    // The main flow with body and publication info.
    {
      set par(justify: true)
      body
      v(1fr)
      set text(0.5em)
    },

    // The sidebar with sidenotes.
    locate(loc => {
      show heading: underline.with(stroke: 2pt, offset: 4pt)
      set par(justify: true)
      let final_absy = absy.final(loc);
      for element in sidenotes.final(loc) {
        place(dy: element.at("pos").at("y") - final_absy)[
          #box(
            width: sidebar-width,
            stroke: (left: 1pt, rest: none),
            outset: (x: 10pt, y: 5pt),
            element.at("body")
          )
        ]
      }
    }),
  )
}

// An sidenote that is displayed in the sidebar. Can be added
// anywhere in the document. All sidenotes are collected automatically.
#let sidenote(body) = {
  locate(loc => {
    let pos = loc.position();
    sidenotes.update(it => it + (("pos": pos, "body": body),))
  });
}

// Store theorem environment numbering

#let thmcounters = state("thm",
  (
    "counters": (
      "heading": (),
      "theorem": (0, 0),
    ),
    "latest": ()
  )
)


#let thmenv(identifier, base, base_level, num, fmt) = {

  let global_numbering = numbering

  return (
    body,
    name: none,
    numbering: "3.1.1",
    base: base,
    base_level: base_level
  ) => {
    let number = none
    if not numbering == none {
      locate(loc => {
        thmcounters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = counter(heading).at(loc)
          if not identifier in counters.keys() {
            counters.insert(identifier, (0, ))
          }

          let tc = counters.at(identifier)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base_level != none {
              if bc.len() < base_level {
                bc = bc + (0,) * (base_level - bc.len())
              } else if bc.len() > base_level{
                bc = bc.slice(0, base_level)
              }
            }

            // Reset counter if the base counter has updated
            if tc.slice(0, -1) == bc {
              counters.at(identifier) = (..bc, tc.last() + 1)
            } else {
              counters.at(identifier) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(identifier) = (tc.last() + 1,)
            let latest = counters.at(identifier)
          }

          if not num == none {
            return (
              "counters": counters,
              "latest": num.split(".").map(int)
            ) 
          }

          let latest = counters.at(identifier)
          return (
            "counters": counters,
            "latest": latest
          )
        })
      })

      number = thmcounters.display(x => {
        return global_numbering(numbering, ..x.at("latest"))
      })
    }

    fmt(name, number, body)
  }
}


#let thmref(
  label,
  fmt: auto,
  makelink: true,
  ..body
) = {
  if fmt == auto {
    fmt = (nums, body) => {
      if body.pos().len() > 0 {
        body = body.pos().join(" ")
        return [#body #numbering("1.1", ..nums)]
      }
      return numbering("1.1", ..nums)
    }
  }

  locate(loc => {
    let elements = query(label, loc)
    let locationreps = elements.map(x => repr(x.location().position())).join(", ")
    assert(elements.len() > 0, message: "label <" + str(label) + "> does not exist in the document: referenced at " + repr(loc.position()))
    assert(elements.len() == 1, message: "label <" + str(label) + "> occurs multiple times in the document: found at " + locationreps)
    let target = elements.first().location()
    let number = thmcounters.at(target).at("latest")
    if makelink {
      return link(target, fmt(number, body))
    }
    return fmt(number, body)
  })
}


#let thmbox(
  identifier,
  head,
  fill: none,
  stroke: none,
  inset: 1.2em,
  radius: 0.3em,
  breakable: false,
  padding: (top: 0.5em, bottom: 0.5em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  base: "heading",
  base_level: none,
  num: none,
) = {
  let boxfmt(name, number, body) = {
    if not name == none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    let title = head
    if not num == none {
      title += " " + num
    } else if not number == none {
      title += " " + number
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    pad(
      ..padding,
      block(
        fill: fill,
        stroke: stroke,
        inset: inset,
        width: 100%,
        radius: radius,
        breakable: breakable,
        [#title#name#h(0.1em):#h(0.2em)#body]
      )
    )
  }
  return thmenv(identifier, base, base_level, num, boxfmt)
}


#let thmplain = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
)


#let leqslant = $\u{2a7d}$


// #import "dotx.typ"
// #import "mathscr.typ"
// #import "fraktur.typ"

#let imath = $\u{1D6A4}$
#let jmath = $\u{1D6A5}$
#let varnothing = $\u{2300}$
#let varsigma = $\u{03C2}$

// Define theorem environments

#let theorem(num) = {
  thmbox(
    "theorem",         // Definitions use their own counter
    "Theorem",
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    num: num,
  )
}

#let lemma(num) = {
  thmbox(
    "theorem",         // Definitions use their own counter
    "Lemma",
    base: "theorem",      // Corollaries are 'attached' to Theorems
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    num: num,
  )
}
#let corollary(num) = {
  thmbox(
    "corollary",         // Definitions use their own counter
    "Corollary",
    base: "theorem",      // Corollaries are 'attached' to Theorems
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    num: num,
  )
}

#let definition(num) = {
  thmbox(
    "definition",         // Definitions use their own counter
    "Definition",
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    num: num,
  )
}

#let propostition(num) = {
  thmbox(
    "propostition",         // Definitions use their own counter
    "Propostition",
    inset: 0em,
    padding: (top: 0em, bottom: 0em),
    num: num,
  )
}

#let exercise = thmbox(
  "exercise",
  "Exercise",
  stroke: rgb("#ffaaaa") + 1pt,
  base: none,           // Unattached: count globally
).with(numbering: "I")  // Use Roman numerals

// Examples and remarks are not numbered
#let example = thmplain("example", "Example").with(numbering: none)
#let remark = thmplain(
  "remark",
  "Remark",
  inset: 0em
).with(numbering: none)

// Proofs are attached to theorems, although they are not numbered
#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  bodyfmt: body => [
    #body #h(1fr) $square$    // Insert QED symbol
  ]
).with(numbering: none)

#let solution = thmplain(
  "solution",
  "Solution",
  base: "exercise",
  inset: 0em,
).with(numbering: none)
