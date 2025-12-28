#let template(resume) = [
  #set line(length: 100%, stroke: 0.5pt + black)
  #set list(indent: 0.5em)
  #set page("us-letter", margin: 0.5in)
  #set par(linebreaks: "simple", leading: 0.7em, spacing: 0.9em)
  #set text(font: "Nimbus Sans L", size: 10pt)

  #show heading.where(level: 1): set text(size: 18pt)
  #show heading.where(level: 2): set block(above: 1.5em)
  #show heading: it => {
    let threshold = 10%
    block(breakable: false, height: threshold)
    v(-threshold, weak: true)
    it
  }

  #let headline(name, desc, detail: none, timing) = {
    box[#pad(right: 0.4em)[*#name*]]
    [#desc]
    if detail != none [
      — #detail
    ]
    h(1fr)
    [#timing]
  }

  #let monthrange(startdate, enddate: none) = {
    let format = "[month repr:short] [year repr:full]"

    startdate.display(format)
    if enddate == none [
      \- Present
    ] else [
      \- #enddate.display(format)
    ]
  }

  #let location(l) = {
    if l == none {
      return none
    }

    if "CityState" in l {
      return [#l.CityState.at(0), #l.CityState.at(1)]
    } else if "Address" in l {
      return [#l.Address.city, #l.Address.region]
    } else if (
      l == "Remote"
    ) {
      return l
    } else {
      panic("unrecognized location kind", l)
    }
  }

  #let when(w) = {
    if w == none {
      return none
    }

    if "Range" in w {
      return monthrange(w.Range.start, enddate: w.Range.end)
    } else if "Started" in w {
      return monthrange(w.Started)
    } else if "Year" in w {
      return w.Year
    } else if "Date" in w {
      return w.Date.display("[month repr:short] [year repr:full]")
    }
  }

  #let education(education) = {
    block[
      #headline(
        (education.kind, education.at("area", default: none))
          .filter(s => s != none and s.len() > 0)
          .join(", "),
        none,
        when(education.when),
      ) \
      #box[
        #education.institution \
        #if education.highlights.len() > 0 {
          [Honors: #education.highlights.join(", ")]
        }, #education.score GPA
      ]
    ]
  }

  #let join-with-linebreaks(container-size, items, sep) = {
    let sep-width = measure(sep).width

    let lines = ()
    let line = ()
    let line-len = 0pt

    for it in items {
      let item-width = measure(it).width
      line-len += item-width + sep-width
      if line-len > container-size.width {
        lines.push(line.join(sep))
        line = ()
        line-len = item-width
      }
      line.push(it)
    }
    if line.len() > 0 {
      lines.push(line.join(sep))
    }

    lines.join("\n")
  }

  #let clincalrotation(cr) = {
    block(breakable: false)[
      #headline(
        cr.context,
        cr.name,
        detail: location(cr.location),
        cr.summary,
      ) \
      #list(..cr.highlights)
    ]
  }

  #let work(w) = {
    block(breakable: false)[
      #headline(
        w.name,
        none,
        when(w.when),
      ) \
      #w.context — #location(w.location)
      #list(..w.highlights)
    ]
  }

  #let italic(text) = {
    let items = text.split("_")

    if items.len() != 3 {
      return text
    }

    let (before, it, after) = items

    return [#before#emph(it)#after]
  }

  #let project(p) = {
    block(breakable: false)[
      #headline(
        p.name,
        none,
        when(p.when),
      ) \
      #p.context — #location(p.location)
      #for h in p.highlights [
        #list.item(italic(h))
      ]
    ]
  }

  #let singleton(item, detail) = {
    list.item([
      #box[#pad(right: 0.4em)[#item]]
      #h(1fr)
      #detail
    ])
  }

  #let nicelink(l) = {
    let authority = l.split(regex("(://)|:")).last()
    link(l)[#authority]
  }

  #let twocolumn(leftcontent, rightcontent) = {
    grid(
      columns: 3,
      leftcontent, h(1fr), rightcontent,
    )
  }

  // DOCUMENT START

  #align(center)[
    = #resume.profile.first_name #resume.profile.last_name
    #resume.contact.personal_email | #resume.contact.phone
  ]

  == Education

  #line()

  #resume.education.map(e => education(e)).join()

  == Clinical Rotations

  #line()

  #let sep = h(.5em) + sym.bullet + h(0.5em)

  #v(0.5em)
  #align(center)[
    #layout(size => {
      join-with-linebreaks(
        size,
        resume
          .experiences
          .filter(e => e.kind == "clinical rotation")
          .map(e => [*#e.context*]),
        sep,
      )
    })
  ]
  #v(0.5em)

  #(
    resume
      .experiences
      .filter(e => e.kind == "clinical rotation" and e.highlights.len() > 0)
      .map(e => clincalrotation(e))
      .join()
  )

  == Work Experience

  #line()

  #(
    resume
      .experiences
      .filter(e => e.kind == "work" and e.highlights.len() > 0)
      .map(e => work(e))
      .join()
  )

  == Scholarly Activities

  #line()

  #(
    resume
      .experiences
      .filter(e => e.kind == "project")
      .map(e => project(e))
      .join()
  )

  == Certifications & Professional Memberships

  #line()

  #(
    resume
      .experiences
      .filter(e => e.kind == "certification" or e.kind == "membership")
      .map(e => singleton(e.name, when(e.when)))
      .join()
  )

  == Community Involvement

  #line()

  #(
    resume
      .experiences
      .filter(e => e.kind == "volunteer")
      .map(e => singleton(e.name, when(e.when)))
      .join()
  )

  // DOCUMENT END
]

#template(toml(sys.inputs.data_path))
